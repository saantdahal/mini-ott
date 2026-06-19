# 🚀 OTT Video Upload System - Implementation TODO

---

## 🧩 Phase 0: Setup & Alignment

- [ ] Confirm AWS credentials setup (.env)
- [ ] Confirm S3 bucket created and private
- [ ] Confirm backend already running (Express + Sequelize)
- [ ] Confirm auth middleware working (req.user available)

---

## 🧱 Phase 1: Database Layer

### 1.1 Create video_uploads model

- [ ] Create Sequelize model: video_uploads
- [ ] Fields:
  - video_upload_id (UUID PK)
  - content_id
  - season_id
  - episode_id
  - upload_for
  - s3_key
  - upload_id
  - status
  - file_name
  - mime_type
  - file_size
  - parts_uploaded
  - initiated_by
  - error_message
- [ ] timestamps: true
- [ ] underscored: true

---

### 1.2 Model Integration

- [ ] Import model into DB index
- [ ] Sync / migrate database
- [ ] Test DB insertion manually

---

## ⚙️ Phase 2: S3 Service Layer

### 2.1 Create S3 client

- [ ] Create `s3.js` service
- [ ] Initialize S3Client using env credentials
- [ ] Test connection

---

### 2.2 Multipart Upload Functions

- [ ] createMultipartUpload()
- [ ] generatePresignedPartUrl()
- [ ] completeMultipartUpload()
- [ ] abortMultipartUpload()

---

## 📦 Phase 3: Upload Controller

---

### 3.1 Init Upload

- [ ] Create controller: initUpload

Tasks:

- [ ] Validate admin (req.user.role)
- [ ] Validate content_id exists
- [ ] Validate episode_id if provided
- [ ] Generate S3 key based on structure
- [ ] Call createMultipartUpload()
- [ ] Create DB row in video_uploads
- [ ] status = "initiated"

---

### 3.2 Sign Part

- [ ] Create controller: signPart

Tasks:

- [ ] Accept video_upload_id + part_number
- [ ] Fetch upload record
- [ ] Validate status
- [ ] Generate presigned URL
- [ ] Return URL

---

### 3.3 Complete Upload

- [ ] Create controller: completeUpload

Tasks:

- [ ] Accept parts[]
- [ ] Call completeMultipartUpload()
- [ ] Update video_uploads.status = "uploaded"

---

### 3.4 DB Mapping After Upload

- [ ] If upload_for = episode_video
      → update episodes.video_key

- [ ] If upload_for = movie_trailer
      → update contents.trailer_key

- [ ] If upload_for = season_trailer
      → update seasons.trailer_key

---

### 3.5 Abort Upload

- [ ] Create controller: abortUpload

Tasks:

- [ ] Call abortMultipartUpload()
- [ ] Update DB status = "aborted"

---

### 3.6 Upload Status

- [ ] Create controller: getUploadStatus
- [ ] Return upload status

---

## 🔗 Phase 4: Routes Integration

- [ ] Create upload.routes.js
- [ ] Add routes:
  - POST /uploads/init
  - POST /uploads/sign-part
  - POST /uploads/complete
  - POST /uploads/abort
  - GET /uploads/:id/status
- [ ] Attach auth middleware

---

## 🔐 Phase 5: Validation & Security

- [ ] Validate file size
- [ ] Validate mime type
- [ ] Restrict admin-only upload
- [ ] Ensure S3 bucket is private
- [ ] Ensure presigned URL expiry (5–15 min)

---

## ⚡ Phase 6: Processing Layer (IMPORTANT)

---

### 6.1 Queue Setup

- [ ] Setup BullMQ / Inngest / Queue system

---

### 6.2 Processing Job

- [ ] Create job: processVideo

Tasks:

- [ ] Transcode video (placeholder)
- [ ] Generate thumbnail (placeholder)
- [ ] Extract duration
- [ ] Update DB

---

### 6.3 Update DB After Processing

- [ ] For episodes:
      → update stream_manifest_key

- [ ] For contents:
      → update stream_manifest_key

---

## 🔁 Phase 7: Status Flow

- [ ] Update statuses:
  - initiated
  - uploading
  - uploaded
  - processing
  - ready
  - failed

---

## 🧹 Phase 8: Cleanup

- [ ] Implement abort for failed uploads
- [ ] Add S3 lifecycle rule (optional)
- [ ] Remove orphan DB records

---

## 🧪 Phase 9: Testing

---

### 9.1 API Testing

- [ ] Test init upload
- [ ] Test part upload (Postman)
- [ ] Test complete upload
- [ ] Test abort upload

---

### 9.2 Edge Cases

- [ ] Large file upload simulation
- [ ] Failed part retry
- [ ] Invalid upload_id
- [ ] Unauthorized access

---

## 📊 Phase 10: Final Integration

- [ ] Link upload to content creation flow
- [ ] Ensure episode video properly linked
- [ ] Ensure movie trailer works
- [ ] Ensure DB consistency

---

## 🚀 Final Goal

- [ ] Upload 10GB+ video successfully
- [ ] Upload does NOT crash backend
- [ ] Resume upload works
- [ ] DB correctly updated
- [ ] Ready for streaming pipeline

---
