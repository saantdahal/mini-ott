# OTT Content Management + Secure Large Video Upload Requirements

## 1. Overview

This document defines the requirements for integrating a scalable and secure video upload system into the existing OTT backend.

The backend already contains a working content schema using Sequelize and PostgreSQL, including:

- `contents`
- `categories`
- `content_categories`
- `genres`
- `content_genres`
- `seasons`
- `episodes`
- `user_content_access`

The goal is to extend this existing system with AWS S3-based large video upload support, while keeping the current database structure intact as much as possible.

---

## 2. Objectives

The system must:

- support content management for movies and series
- support large video uploads securely
- support scalable upload handling for very large files
- integrate with the existing `contents`, `seasons`, and `episodes` tables
- avoid backend bottlenecks during upload
- prepare uploaded videos for future streaming pipeline
- support admin-controlled publishing workflow

---

## 3. Existing Database Models

The current backend already has the following data structure:

### 3.1 `contents`

Used as the main content entity.

Supports:

- movie
- series
- trailer metadata
- posters / thumbnail / banners
- stream manifest reference
- publishing status
- content access type

Important fields already available:

- `content_id`
- `title`
- `slug`
- `description`
- `content_type`
- `is_series`
- `release_date`
- `duration_seconds`
- `thumbnail_key`
- `poster_key`
- `banner_key`
- `trailer_key`
- `stream_manifest_key`
- `access_type`
- `required_coins`
- `status`
- `published_at`
- `created_by`
- `updated_by`

---

### 3.2 `categories` and `content_categories`

Used to classify contents into content categories.

Examples:

- movies
- series
- documentaries
- kids
- trending

---

### 3.3 `genres` and `content_genres`

Used to classify contents into genres.

Examples:

- action
- comedy
- thriller
- romance

---

### 3.4 `seasons`

Used when a content is a series.

Important fields:

- `season_id`
- `content_id`
- `season_number`
- `title`
- `description`
- `thumbnail_key`
- `trailer_key`
- `release_date`
- `status`

---

### 3.5 `episodes`

Used to store episode-level metadata and video references.

Important fields:

- `episode_id`
- `content_id`
- `season_id`
- `episode_number`
- `title`
- `slug`
- `description`
- `thumbnail_key`
- `banner_key`
- `video_key`
- `stream_manifest_key`
- `subtitle_key`
- `duration_seconds`
- `release_date`
- `access_type`
- `required_coins`
- `view_count`
- `status`

---

### 3.6 `user_content_access`

Used to grant access to paid or restricted contents or episodes.

Important fields:

- `user_id`
- `content_id`
- `episode_id`
- `access_type`
- `granted_at`
- `expires_at`
- `status`

This table will remain the source of truth for entitlement/access checks.

---

## 4. Content Structure Rules

### 4.1 Movie

A movie will be stored in `contents`.

Rules:

- `is_series = false`
- movie-level metadata stored in `contents`
- processed streaming path may be stored in `contents.stream_manifest_key`
- trailer may be stored in `contents.trailer_key`

---

### 4.2 Series

A series will also be stored in `contents`.

Rules:

- `is_series = true`
- seasons stored in `seasons`
- episodes stored in `episodes`
- actual watchable video is generally stored per episode
- `contents.total_seasons` and `contents.total_episodes` should be maintained

---

### 4.3 Episode

An episode is stored in `episodes`.

Rules:

- each episode belongs to one `content`
- may belong to one `season`
- raw uploaded video key stored in `episodes.video_key`
- processed streaming manifest stored in `episodes.stream_manifest_key`

---

## 5. Upload Architecture Requirements

Amazon S3 supports multipart uploads for large objects, and multipart upload allows parts to be uploaded independently and retried without restarting the whole upload. S3 multipart upload is intended for large uploads and supports objects up to 50 TB. Presigned URLs can be used to grant time-limited permission for upload without exposing AWS credentials. :contentReference[oaicite:0]{index=0}

### 5.1 Core Principle

The backend must act as the **control layer**, not the heavy file relay layer.

That means:

- backend authenticates admin
- backend verifies target content/episode
- backend initiates multipart upload
- backend generates presigned part URLs
- backend completes or aborts upload
- backend stores upload result in the database

### 5.2 Why this architecture is required

Very large uploads should not be fully buffered or proxied through the application server because that creates unnecessary RAM, CPU, and bandwidth pressure. Multipart upload allows individual parts to be retried independently, and incomplete multipart uploads must be completed or aborted to stop being charged for uploaded parts. :contentReference[oaicite:1]{index=1}

---

## 6. Upload Use Cases

### 6.1 Upload movie trailer

Target table:

- `contents.trailer_key`

### 6.2 Upload movie main video

Recommended:

- store raw object in S3
- after processing, store playable manifest in `contents.stream_manifest_key`

### 6.3 Upload season trailer

Target table:

- `seasons.trailer_key`

### 6.4 Upload episode raw video

Target table:

- `episodes.video_key`

### 6.5 Upload episode processed streaming output

Target table:

- `episodes.stream_manifest_key`

### 6.6 Upload thumbnails / banners / posters / subtitles

Possible fields:

- `contents.thumbnail_key`
- `contents.poster_key`
- `contents.banner_key`
- `episodes.thumbnail_key`
- `episodes.banner_key`
- `episodes.subtitle_key`
- `seasons.thumbnail_key`

---

## 7. S3 Key Structure

To keep uploads organized, S3 object keys should follow a deterministic structure.

### 7.1 Content-level files

- `contents/{content_id}/thumbnail/...`
- `contents/{content_id}/poster/...`
- `contents/{content_id}/banner/...`
- `contents/{content_id}/trailer/...`
- `contents/{content_id}/raw/...`
- `contents/{content_id}/processed/...`

### 7.2 Season-level files

- `contents/{content_id}/seasons/{season_id}/thumbnail/...`
- `contents/{content_id}/seasons/{season_id}/trailer/...`

### 7.3 Episode-level files

- `contents/{content_id}/seasons/{season_id}/episodes/{episode_id}/raw/...`
- `contents/{content_id}/seasons/{season_id}/episodes/{episode_id}/processed/...`
- `contents/{content_id}/seasons/{season_id}/episodes/{episode_id}/thumbnail/...`
- `contents/{content_id}/seasons/{season_id}/episodes/{episode_id}/subtitle/...`

---

## 8. Recommended Additional Upload Tracking Table

The current models are strong for content metadata, but multipart upload orchestration needs a dedicated upload tracking table.

### 8.1 Proposed table: `video_uploads`

Suggested fields:

- `video_upload_id` UUID PK
- `content_id` UUID nullable
- `season_id` UUID nullable
- `episode_id` UUID nullable
- `upload_for` STRING
  - values: `movie_video`, `movie_trailer`, `episode_video`, `season_trailer`, `thumbnail`, `poster`, `banner`, `subtitle`
- `s3_key` STRING not null
- `upload_id` STRING not null
- `status` STRING not null
  - values: `initiated`, `uploading`, `uploaded`, `processing`, `completed`, `failed`, `aborted`
- `file_name` STRING nullable
- `mime_type` STRING nullable
- `file_size` BIGINT nullable
- `parts_uploaded` INTEGER default 0
- `initiated_by` UUID not null
- `error_message` TEXT nullable
- `created_at`
- `updated_at`

### 8.2 Why this table is needed

The existing `contents` and `episodes` tables are content metadata tables. They should not be overloaded with multipart upload session state like `upload_id`, part counts, retry state, or temporary upload failures.

This new table will:

- track upload sessions
- track status changes
- help resume uploads
- help debug failed uploads
- keep content tables clean

---

## 9. Upload API Requirements

### 9.1 Init upload

**Endpoint:** `POST /admin/uploads/init`

Purpose:

- authenticate admin
- validate upload target
- create multipart upload in S3
- create `video_uploads` row
- return upload session details

Input:

```json
{
  "upload_for": "episode_video",
  "content_id": "uuid",
  "season_id": "uuid",
  "episode_id": "uuid",
  "file_name": "episode-1.mp4",
  "mime_type": "video/mp4",
  "file_size": 1099511627776
}
```
