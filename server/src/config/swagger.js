const swaggerUi = require("swagger-ui-express");

const buildOpenApiSpec = () => {
  const port = process.env.PORT || "3000";
  const baseUrl = process.env.API_BASE_URL || `http://localhost:${port}`;

  return {
    openapi: "3.0.3",
    info: {
      title: "Mini OTT Platform API",
      version: "1.0.0",
      description: "API documentation for Mini OTT backend services.",
    },
    servers: [
      {
        url: baseUrl,
        description: "Active API server",
      },
    ],
    tags: [
      {
        name: "Auth",
        description:
          "Authentication endpoints - Register, Login, OTP verification, Forgot password, Token refresh",
      },
      {
        name: "Users",
        description: "User profile management - View and update user profiles",
      },
      {
        name: "Khalti Payments",
        description: "Khalti ePayment integration for coin package purchases",
      },
      {
        name: "eSewa Payments",
        description: "eSewa ePay integration for coin package purchases",
      },
      {
        name: "Coin Packages",
        description:
          "Coin package management - Create and list purchasable coin bundles",
      },
      {
        name: "Wallet",
        description: "Wallet endpoints - User coin balance",
      },
      {
        name: "Video Uploads",
        description:
          "Video upload lifecycle - Direct upload + HLS transcode and legacy S3 multipart flow (admin only)",
      },
      {
        name: "Transcoding",
        description:
          "HLS transcoding jobs - Trigger adaptive transcode and poll job status (admin only)",
      },
      {
        name: "Streaming",
        description:
          "Streaming endpoints - Signed CloudFront HLS manifest URLs (admin only)",
      },
      {
        name: "Categories",
        description: "Content categories - CRUD for category taxonomy",
      },
      {
        name: "Genres",
        description: "Content genres - CRUD for genre taxonomy",
      },
      {
        name: "Contents",
        description:
          "Contents (movies, series, documentaries) - CRUD with category/genre association, paginated listing, cascade delete",
      },
      {
        name: "Seasons",
        description:
          "Seasons under a content (series only) - CRUD nested by content_id",
      },
      {
        name: "Episodes",
        description:
          "Episodes under a content/season - CRUD with video/subtitle metadata and access control",
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
      schemas: {
        RegisterRequest: {
          type: "object",
          required: ["full_name", "email", "password"],
          properties: {
            full_name: { type: "string", example: "Santosh Dahal" },
            email: {
              type: "string",
              format: "email",
              example: "santosh@example.com",
            },
            password: {
              type: "string",
              minLength: 8,
              example: "StrongPass123",
            },
            auth_provider: {
              type: "string",
              enum: ["email", "google", "apple"],
              default: "email",
            },
            phone: {
              type: "string",
              nullable: true,
              example: "+9779800000000",
            },
            country: { type: "string", nullable: true, example: "Nepal" },
            gender: {
              type: "string",
              enum: ["male", "female", "other"],
              nullable: true,
            },
            date_of_birth: {
              type: "string",
              format: "date",
              nullable: true,
              example: "2000-01-15",
            },
            avatar_key: {
              type: "string",
              nullable: true,
              example: "avatars/user-01.png",
            },
          },
        },
        CreateAdminRequest: {
          type: "object",
          required: ["full_name", "email", "password"],
          properties: {
            full_name: { type: "string", example: "Admin User" },
            email: {
              type: "string",
              format: "email",
              example: "admin2@example.com",
            },
            password: {
              type: "string",
              minLength: 8,
              example: "StrongAdminPass123",
            },
            phone: {
              type: "string",
              nullable: true,
              example: "+9779800000000",
            },
            country: { type: "string", nullable: true, example: "Nepal" },
            gender: {
              type: "string",
              enum: ["male", "female", "other"],
              nullable: true,
            },
            date_of_birth: {
              type: "string",
              format: "date",
              nullable: true,
              example: "1995-05-20",
            },
            avatar_key: {
              type: "string",
              nullable: true,
              example: "https://cdn.example.com/avatar.png",
            },
          },
        },
        LoginRequest: {
          type: "object",
          required: ["email", "password"],
          properties: {
            email: {
              type: "string",
              format: "email",
              example: "santosh@example.com",
            },
            password: {
              type: "string",
              minLength: 8,
              example: "StrongPass123",
            },
          },
        },
        RefreshRequest: {
          type: "object",
          required: ["refreshToken"],
          properties: {
            refreshToken: {
              type: "string",
              example: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
            },
          },
        },
        VerifyOtpRequest: {
          type: "object",
          required: ["email", "otp"],
          properties: {
            email: {
              type: "string",
              format: "email",
              example: "santosh@example.com",
            },
            otp: { type: "string", example: "123456" },
          },
        },
        ResendOtpRequest: {
          type: "object",
          required: ["email"],
          properties: {
            email: {
              type: "string",
              format: "email",
              example: "santosh@example.com",
            },
          },
        },
        ForgotPasswordRequest: {
          type: "object",
          required: ["email"],
          properties: {
            email: {
              type: "string",
              format: "email",
              example: "santosh@example.com",
            },
          },
        },
        VerifyResetOtpRequest: {
          type: "object",
          required: ["email", "otp"],
          properties: {
            email: {
              type: "string",
              format: "email",
              example: "santosh@example.com",
            },
            otp: { type: "string", example: "123456" },
          },
        },
        ResetPasswordRequest: {
          type: "object",
          required: ["email", "otp", "new_password"],
          properties: {
            email: {
              type: "string",
              format: "email",
              example: "santosh@example.com",
            },
            otp: { type: "string", example: "123456" },
            new_password: {
              type: "string",
              minLength: 8,
              example: "NewStrongPass123",
            },
          },
        },
        ChangePasswordRequest: {
          type: "object",
          required: ["current_password", "new_password"],
          properties: {
            current_password: {
              type: "string",
              minLength: 8,
              example: "CurrentStrongPass123",
            },
            new_password: {
              type: "string",
              minLength: 8,
              example: "NewStrongPass123",
            },
          },
        },
        GoogleMobileLoginRequest: {
          type: "object",
          required: ["idToken"],
          properties: {
            idToken: {
              type: "string",
              example: "eyJhbGciOiJSUzI1NiIsImtpZCI6Ij...",
            },
          },
        },
        AppleMobileLoginRequest: {
          type: "object",
          required: ["identityToken"],
          properties: {
            identityToken: {
              type: "string",
              example: "eyJraWQiOiJ...",
            },
            email: {
              type: "string",
              format: "email",
              example: "santosh@example.com",
              description: "Recommended on first Apple sign-in from mobile",
            },
            full_name: {
              type: "string",
              example: "Santosh Dahal",
            },
          },
        },
        AuthTokens: {
          type: "object",
          properties: {
            accessToken: { type: "string" },
            refreshToken: { type: "string" },
          },
        },
        User: {
          type: "object",
          properties: {
            user_id: { type: "string", format: "uuid" },
            full_name: { type: "string" },
            email: { type: "string", format: "email" },
            phone: { type: "string", nullable: true },
            auth_provider: { type: "string" },
            avatar_key: { type: "string", nullable: true },
            role: { type: "string" },
            gender: { type: "string", nullable: true },
            date_of_birth: { type: "string", format: "date", nullable: true },
            country: { type: "string", nullable: true },
            is_email_verified: { type: "boolean" },
            status: { type: "string" },
            last_login_at: {
              type: "string",
              format: "date-time",
              nullable: true,
            },
            created_at: { type: "string", format: "date-time" },
            updated_at: { type: "string", format: "date-time" },
          },
        },
        AuthResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: { type: "string" },
            user: { $ref: "#/components/schemas/User" },
            tokens: { $ref: "#/components/schemas/AuthTokens" },
          },
        },
        ErrorResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: false },
            message: { type: "string", example: "Invalid email or password" },
          },
        },
        UpdateProfileRequest: {
          type: "object",
          properties: {
            full_name: { type: "string", example: "Santosh Dahal" },
            phone: {
              type: "string",
              nullable: true,
              example: "+9779800000000",
            },
            country: { type: "string", nullable: true, example: "Nepal" },
            gender: {
              type: "string",
              enum: ["male", "female", "other"],
              nullable: true,
            },
            date_of_birth: {
              type: "string",
              format: "date",
              nullable: true,
              example: "2000-01-15",
            },
            avatar: {
              type: "string",
              format: "binary",
              nullable: true,
              description: "User profile image",
            },
          },
        },
        UserResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            user: { $ref: "#/components/schemas/User" },
          },
        },
        UsersListResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            users: {
              type: "array",
              items: { $ref: "#/components/schemas/User" },
            },
          },
        },
        MessageResponse: {
          type: "object",
          properties: {
            message: { type: "string", example: "Payment successful" },
            error: {
              type: "string",
              nullable: true,
              example: "Failed to initiate Khalti payment",
            },
          },
        },
        CreateCoinPackageRequest: {
          type: "object",
          required: ["title", "coins", "price_amount"],
          properties: {
            title: {
              type: "string",
              maxLength: 150,
              example: "Starter Pack",
            },
            description: {
              type: "string",
              nullable: true,
              example: "Get started with 100 coins",
            },
            coins: { type: "integer", example: 100 },
            bonus_coins: { type: "integer", default: 0, example: 10 },
            price_amount: {
              type: "number",
              format: "decimal",
              example: 199.0,
              description: "Price in NPR",
            },
            currency: {
              type: "string",
              maxLength: 10,
              default: "NPR",
              example: "NPR",
            },
            is_popular: { type: "boolean", default: false, example: false },
            sort_order: {
              type: "integer",
              nullable: true,
              example: 1,
              description:
                "Display order. Leave blank to auto-assign the next available value.",
            },
            status: {
              type: "string",
              maxLength: 30,
              default: "active",
              enum: ["active", "inactive"],
              example: "active",
            },
          },
        },
        CoinPackage: {
          type: "object",
          properties: {
            coin_package_id: { type: "string", format: "uuid" },
            title: { type: "string" },
            description: { type: "string", nullable: true },
            coins: { type: "integer" },
            bonus_coins: { type: "integer" },
            price_amount: { type: "string", example: "199.00" },
            currency: { type: "string" },
            is_popular: { type: "boolean" },
            sort_order: { type: "integer" },
            status: { type: "string" },
            created_at: { type: "string", format: "date-time" },
            updated_at: { type: "string", format: "date-time" },
          },
        },
        KhaltiInitializePaymentRequest: {
          type: "object",
          required: ["packageId", "price", "packageName", "website_url"],
          properties: {
            packageId: {
              type: "string",
              format: "uuid",
              example: "6b7e3c0b-3e3a-4a2f-8f6b-0b8a2b9e8c11",
            },
            price: {
              type: "number",
              example: 199.0,
              description: "Amount in NPR",
            },
            packageName: { type: "string", example: "Starter Pack" },
            website_url: {
              type: "string",
              format: "uri",
              example: "https://your-frontend.example.com",
            },
          },
        },
        KhaltiInitializePaymentResponse: {
          type: "object",
          properties: {
            message: { type: "string", example: "Purchase successful" },
            paymentInitiate: {
              type: "object",
              description: "Raw response from Khalti initiate API",
              additionalProperties: true,
              example: {
                pidx: "TBL6Vj8p9mP7wXk9xCzZ7k",
                payment_url: "https://khalti.com/...",
                expires_in: 1800,
              },
            },
            createPendingPurchase: {
              type: "object",
              description:
                "Created payments row (Sequelize instance serialized)",
              additionalProperties: true,
            },
          },
        },
        KhaltiCompletePaymentSuccessResponse: {
          type: "object",
          properties: {
            message: { type: "string", example: "Payment successful" },
            data: {
              type: "object",
              properties: {
                payment_id: { type: "string", format: "uuid" },
                transaction_id: { type: "string", example: "khalti_txn_123" },
                coins_credited: { type: "integer", example: 120 },
                wallet: {
                  type: "object",
                  nullable: true,
                  additionalProperties: true,
                  description:
                    "Wallet service response (shape depends on wallet implementation)",
                },
              },
            },
          },
        },
        EsewaInitializePaymentRequest: {
          type: "object",
          required: ["packageId", "price"],
          properties: {
            packageId: {
              type: "string",
              format: "uuid",
              example: "6b7e3c0b-3e3a-4a2f-8f6b-0b8a2b9e8c11",
            },
            price: {
              type: "number",
              example: 199.0,
              description: "Amount in NPR",
            },
          },
        },
        EsewaInitializePaymentResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            payment: {
              type: "object",
              properties: {
                signature: { type: "string" },
                signed_field_names: {
                  type: "string",
                  example: "total_amount,transaction_uuid,product_code",
                },
                total_amount: {
                  type: "string",
                  example: "199.00",
                  description:
                    "Must match the value used while generating signature",
                },
                transaction_uuid: { type: "string", format: "uuid" },
                product_code: { type: "string", example: "EPAYTEST" },
                success_url: { type: "string", format: "uri" },
                failure_url: { type: "string", format: "uri" },
                gateway_url: { type: "string", format: "uri" },
                gateway_action_url: { type: "string", format: "uri" },
              },
              additionalProperties: true,
            },
            purchasedItemData: {
              type: "object",
              description:
                "Created payments row (Sequelize instance serialized)",
              additionalProperties: true,
            },
          },
        },
        EsewaCompletePaymentSuccessResponse: {
          type: "object",
          properties: {
            message: { type: "string", example: "Payment successful" },
            data: {
              type: "object",
              properties: {
                payment_id: { type: "string", format: "uuid" },
                transaction_id: {
                  type: "string",
                  nullable: true,
                  example: "0000TEST",
                },
                coins_credited: { type: "integer", example: 120 },
                wallet: {
                  type: "object",
                  nullable: true,
                  additionalProperties: true,
                  description:
                    "Wallet service response (shape depends on wallet implementation)",
                },
              },
            },
          },
        },
        WalletCoinsResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: {
              type: "string",
              example: "User coins fetched successfully",
            },
            data: {
              type: "object",
              additionalProperties: true,
              description:
                "Wallet service response containing current coin balance and wallet metadata",
              example: {
                balance_coins: 420,
                total_earned: 500,
                total_spent: 80,
              },
            },
          },
        },
        PaymentHistoryUser: {
          type: "object",
          nullable: true,
          properties: {
            user_id: { type: "string", format: "uuid" },
            full_name: { type: "string", example: "Santosh Dahal" },
            email: {
              type: "string",
              format: "email",
              example: "santosh@example.com",
            },
            phone: {
              type: "string",
              nullable: true,
              example: "+9779800000000",
            },
            role: { type: "string", example: "user" },
          },
        },
        PaymentHistoryCoinPackage: {
          type: "object",
          nullable: true,
          properties: {
            coin_package_id: { type: "string", format: "uuid" },
            title: { type: "string", example: "Starter Pack" },
            coins: { type: "integer", example: 100 },
            bonus_coins: { type: "integer", example: 20 },
            price_amount: {
              type: "string",
              nullable: true,
              example: "199.00",
            },
          },
        },
        PaymentHistoryItem: {
          type: "object",
          properties: {
            payment_id: { type: "string", format: "uuid" },
            amount: { type: "string", example: "199.00" },
            currency: { type: "string", example: "NPR" },
            status: { type: "string", example: "completed" },
            gateway: { type: "string", example: "khalti" },
            gateway_transaction_id: {
              type: "string",
              nullable: true,
              example: "khalti_txn_123",
            },
            gateway_reference: {
              type: "string",
              nullable: true,
              example: "Khalti Payment Gateway",
            },
            payment_for: { type: "string", example: "coin_purchase" },
            coins_credited: { type: "integer", example: 120 },
            paid_at: {
              type: "string",
              format: "date-time",
              nullable: true,
            },
            created_at: { type: "string", format: "date-time" },
            user: { $ref: "#/components/schemas/PaymentHistoryUser" },
            coin_package: {
              $ref: "#/components/schemas/PaymentHistoryCoinPackage",
            },
          },
        },
        WalletPaymentHistoryResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: {
              type: "string",
              example: "Payment history fetched successfully",
            },
            data: {
              type: "object",
              properties: {
                items: {
                  type: "array",
                  items: { $ref: "#/components/schemas/PaymentHistoryItem" },
                },
                pagination: {
                  type: "object",
                  properties: {
                    page: { type: "integer", example: 1 },
                    limit: { type: "integer", example: 10 },
                    total: { type: "integer", example: 32 },
                    total_pages: { type: "integer", example: 4 },
                  },
                },
                filters: {
                  type: "object",
                  properties: {
                    from_date: {
                      type: "string",
                      nullable: true,
                      example: "2026-05-01",
                    },
                    to_date: {
                      type: "string",
                      nullable: true,
                      example: "2026-05-09",
                    },
                    status: {
                      type: "string",
                      nullable: true,
                      example: "completed",
                    },
                    gateway: {
                      type: "string",
                      nullable: true,
                      example: "khalti",
                    },
                    user_id: {
                      type: "string",
                      nullable: true,
                      example: "d7d8d874-8b89-4f16-8447-83df4a7f7134",
                    },
                  },
                },
              },
            },
          },
          example: {
            success: true,
            message: "Payment history fetched successfully",
            data: {
              items: [
                {
                  payment_id: "8f24fb89-f5e7-4dca-9cd5-cf2a6efdd153",
                  amount: "199.00",
                  currency: "NPR",
                  status: "completed",
                  gateway: "khalti",
                  gateway_transaction_id: "khalti_txn_123",
                  gateway_reference: "Khalti Payment Gateway",
                  payment_for: "coin_purchase",
                  coins_credited: 120,
                  paid_at: "2026-05-09T10:15:00.000Z",
                  created_at: "2026-05-09T10:10:00.000Z",
                  user: {
                    user_id: "d7d8d874-8b89-4f16-8447-83df4a7f7134",
                    full_name: "Santosh Dahal",
                    email: "santosh@example.com",
                    phone: "+9779800000000",
                    role: "user",
                  },
                  coin_package: {
                    coin_package_id: "ad98f0e0-b70d-4bc8-8d7f-1f0444afd88d",
                    title: "Starter Pack",
                    coins: 100,
                    bonus_coins: 20,
                    price_amount: "199.00",
                  },
                },
              ],
              pagination: {
                page: 1,
                limit: 10,
                total: 1,
                total_pages: 1,
              },
              filters: {
                from_date: "2026-05-01",
                to_date: "2026-05-09",
                status: "completed",
                gateway: "khalti",
                user_id: "d7d8d874-8b89-4f16-8447-83df4a7f7134",
              },
            },
          },
        },
        InitUploadRequest: {
          type: "object",
          required: [
            "content_id",
            "upload_for",
            "file_name",
            "mime_type",
            "file_size",
          ],
          properties: {
            content_id: {
              type: "string",
              format: "uuid",
              example: "bcf0d1f1-4e7a-4a19-b2a7-2b6f0f1a2b3c",
            },
            season_id: {
              type: "string",
              format: "uuid",
              nullable: true,
              example: null,
            },
            episode_id: {
              type: "string",
              format: "uuid",
              nullable: true,
              example: null,
            },
            upload_for: {
              type: "string",
              enum: ["episode_video", "movie_trailer", "season_trailer"],
              example: "episode_video",
            },
            file_name: { type: "string", example: "episode-01.mp4" },
            mime_type: { type: "string", example: "video/mp4" },
            file_size: {
              type: "integer",
              example: 524288000,
              description: "File size in bytes",
            },
          },
        },
        InitUploadResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: { type: "string", example: "Upload initiated" },
            video_upload_id: { type: "string", format: "uuid" },
            upload_id: {
              type: "string",
              description: "S3 multipart upload identifier",
            },
            s3_key: { type: "string" },
            status: { type: "string", example: "initiated" },
          },
        },
        SignPartRequest: {
          type: "object",
          required: ["video_upload_id", "part_number"],
          properties: {
            video_upload_id: { type: "string", format: "uuid" },
            part_number: {
              type: "integer",
              minimum: 1,
              maximum: 10000,
              example: 1,
            },
          },
        },
        SignPartResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: { type: "string", example: "Presigned URL generated" },
            url: { type: "string", format: "uri" },
            expires_in_seconds: { type: "integer", example: 600 },
          },
        },
        SavePartRequest: {
          type: "object",
          required: ["video_upload_id", "part_number", "etag"],
          properties: {
            video_upload_id: { type: "string", format: "uuid" },
            part_number: {
              type: "integer",
              minimum: 1,
              maximum: 10000,
              example: 1,
            },
            etag: {
              type: "string",
              example: '"d41d8cd98f00b204e9800998ecf8427e"',
              description: "ETag returned by S3 for the uploaded part",
            },
          },
        },
        SavePartResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: { type: "string", example: "Part saved" },
            parts_uploaded: {
              type: "array",
              items: {
                type: "object",
                properties: {
                  partNumber: { type: "integer", example: 1 },
                  etag: { type: "string" },
                },
              },
            },
          },
        },
        CompleteUploadRequest: {
          type: "object",
          required: ["video_upload_id", "parts"],
          properties: {
            video_upload_id: { type: "string", format: "uuid" },
            parts: {
              type: "array",
              minItems: 1,
              items: {
                type: "object",
                required: ["PartNumber", "ETag"],
                properties: {
                  PartNumber: {
                    type: "integer",
                    minimum: 1,
                    maximum: 10000,
                    example: 1,
                  },
                  ETag: {
                    type: "string",
                    example: '"d41d8cd98f00b204e9800998ecf8427e"',
                  },
                },
              },
            },
          },
        },
        CompleteUploadResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: { type: "string", example: "Upload completed" },
            status: { type: "string", example: "uploaded" },
            s3_key: { type: "string" },
            location: { type: "string", nullable: true },
            etag: { type: "string", nullable: true },
          },
        },
        AbortUploadRequest: {
          type: "object",
          required: ["video_upload_id"],
          properties: {
            video_upload_id: { type: "string", format: "uuid" },
          },
        },
        AbortUploadResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: { type: "string", example: "Upload aborted" },
            status: { type: "string", example: "aborted" },
          },
        },
        VideoUpload: {
          type: "object",
          properties: {
            video_upload_id: { type: "string", format: "uuid" },
            content_id: { type: "string", format: "uuid" },
            season_id: { type: "string", format: "uuid", nullable: true },
            episode_id: { type: "string", format: "uuid", nullable: true },
            upload_for: {
              type: "string",
              enum: ["episode_video", "movie_trailer", "season_trailer"],
            },
            s3_key: { type: "string" },
            upload_id: { type: "string", nullable: true },
            status: {
              type: "string",
              enum: [
                "initiated",
                "uploading",
                "uploaded",
                "failed",
                "aborted",
                "cancelled",
              ],
            },
            file_name: { type: "string" },
            mime_type: { type: "string" },
            file_size: { type: "integer" },
            parts_uploaded: {
              type: "array",
              nullable: true,
              items: {
                type: "object",
                properties: {
                  partNumber: { type: "integer" },
                  etag: { type: "string" },
                },
              },
            },
            initiated_by: { type: "string", format: "uuid" },
            error_message: { type: "string", nullable: true },
            created_at: { type: "string", format: "date-time" },
            updated_at: { type: "string", format: "date-time" },
          },
        },
        UploadStatusResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: { type: "string", example: "Upload status" },
            result: { $ref: "#/components/schemas/VideoUpload" },
          },
        },
        PlaybackUrlResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: { type: "string", example: "Playback URL generated" },
            data: {
              type: "object",
              properties: {
                url: { type: "string", format: "uri" },
                expires_in: {
                  type: "integer",
                  example: 3600,
                  description: "Seconds until signed URL expires",
                },
              },
            },
          },
        },
        DirectUploadResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: {
              type: "string",
              example:
                "Video ready for playback. Adaptive transcode queued in background.",
            },
            data: {
              type: "object",
              properties: {
                video_upload_id: { type: "string", format: "uuid" },
                transcoding_job_id: { type: "string", format: "uuid" },
                manifest_key: {
                  type: "string",
                  example: "contents/{id}/episodes/{id}/hls/master.m3u8",
                },
                phase: { type: "string", example: "instant_ready" },
                adaptive_status: { type: "string", example: "queued" },
              },
            },
          },
        },
        TranscodingJob: {
          type: "object",
          properties: {
            transcoding_job_id: { type: "string", format: "uuid" },
            video_upload_id: { type: "string", format: "uuid" },
            status: {
              type: "string",
              enum: [
                "queued",
                "pending",
                "progressing",
                "complete",
                "error",
                "cancelled",
              ],
            },
            progress_percent: { type: "integer", nullable: true, example: 65 },
            output_manifest_key: { type: "string", nullable: true },
            output_path_prefix: { type: "string", nullable: true },
            error_message: { type: "string", nullable: true },
            completed_at: {
              type: "string",
              format: "date-time",
              nullable: true,
            },
            created_at: { type: "string", format: "date-time" },
          },
        },
        StartTranscodingResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: {
              type: "string",
              example:
                "Transcoding started (FFmpeg). Poll status for progress.",
            },
            data: {
              type: "object",
              properties: {
                transcoding_job_id: { type: "string", format: "uuid" },
                status: { type: "string", example: "progressing" },
              },
            },
          },
        },
        TranscodingStatusResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: { type: "string", example: "Transcoding status" },
            data: { $ref: "#/components/schemas/TranscodingJob" },
          },
        },
        HlsPlaybackResponse: {
          type: "object",
          properties: {
            success: { type: "boolean", example: true },
            message: {
              type: "string",
              example: "HLS playback params generated",
            },
            data: {
              type: "object",
              properties: {
                manifest_url: {
                  type: "string",
                  format: "uri",
                  description:
                    "Full signed CloudFront URL to master.m3u8 (includes query params)",
                },
                query_params: {
                  type: "string",
                  description:
                    "CloudFront signed cookies/query for segment requests",
                },
                base_url: {
                  type: "string",
                  format: "uri",
                  description: "CloudFront URL prefix for HLS segments",
                },
                expires_in: { type: "integer", example: 3600 },
                phase: {
                  type: "string",
                  enum: ["instant", "adaptive"],
                  example: "instant",
                },
              },
            },
          },
        },
        Category: {
          type: "object",
          properties: {
            category_id: { type: "string", format: "uuid" },
            name: { type: "string", example: "Action" },
            slug: { type: "string", example: "action" },
            description: { type: "string", nullable: true },
            sort_order: { type: "integer", nullable: true, example: 1 },
            status: { type: "string", enum: ["active", "inactive"] },
            created_at: { type: "string", format: "date-time" },
            updated_at: { type: "string", format: "date-time" },
          },
        },
        CreateCategoryRequest: {
          type: "object",
          required: ["name"],
          properties: {
            name: {
              type: "string",
              maxLength: 100,
              example: "Action",
            },
            slug: {
              type: "string",
              maxLength: 120,
              nullable: true,
              example: "action",
              description:
                "Lowercase slug (a-z, 0-9, dashes). Auto-derived from name if omitted.",
            },
            description: {
              type: "string",
              nullable: true,
              maxLength: 2000,
              example: "High-octane action titles",
            },
            sort_order: { type: "integer", minimum: 0, nullable: true },
            status: {
              type: "string",
              enum: ["active", "inactive"],
              default: "active",
            },
          },
        },
        UpdateCategoryRequest: {
          type: "object",
          minProperties: 1,
          properties: {
            name: { type: "string", maxLength: 100 },
            slug: { type: "string", maxLength: 120 },
            description: { type: "string", nullable: true, maxLength: 2000 },
            sort_order: { type: "integer", minimum: 0 },
            status: { type: "string", enum: ["active", "inactive"] },
          },
        },
        Genre: {
          type: "object",
          properties: {
            genre_id: { type: "string", format: "uuid" },
            name: { type: "string", example: "Thriller" },
            slug: { type: "string", example: "thriller" },
            description: { type: "string", nullable: true },
            status: { type: "string", enum: ["active", "inactive"] },
            created_at: { type: "string", format: "date-time" },
            updated_at: { type: "string", format: "date-time" },
          },
        },
        CreateGenreRequest: {
          type: "object",
          required: ["name"],
          properties: {
            name: { type: "string", maxLength: 100, example: "Thriller" },
            slug: {
              type: "string",
              maxLength: 120,
              nullable: true,
              example: "thriller",
            },
            description: {
              type: "string",
              nullable: true,
              maxLength: 2000,
            },
            status: {
              type: "string",
              enum: ["active", "inactive"],
              default: "active",
            },
          },
        },
        UpdateGenreRequest: {
          type: "object",
          minProperties: 1,
          properties: {
            name: { type: "string", maxLength: 100 },
            slug: { type: "string", maxLength: 120 },
            description: { type: "string", nullable: true, maxLength: 2000 },
            status: { type: "string", enum: ["active", "inactive"] },
          },
        },
        Content: {
          type: "object",
          properties: {
            content_id: { type: "string", format: "uuid" },
            title: { type: "string", example: "The Last Horizon" },
            slug: { type: "string", example: "the-last-horizon" },
            description: { type: "string", nullable: true },
            short_description: { type: "string", nullable: true },
            content_type: {
              type: "string",
              enum: ["movie", "series", "documentary", "short"],
              example: "movie",
            },
            is_series: { type: "boolean", example: false },
            language: { type: "string", nullable: true, example: "English" },
            country: { type: "string", nullable: true, example: "USA" },
            age_rating: { type: "string", nullable: true, example: "PG-13" },
            release_date: {
              type: "string",
              format: "date",
              nullable: true,
              example: "2024-08-15",
            },
            duration_seconds: {
              type: "integer",
              nullable: true,
              example: 7200,
            },
            total_seasons: { type: "integer", example: 0 },
            total_episodes: { type: "integer", example: 0 },
            thumbnail_key: { type: "string", nullable: true },
            poster_key: { type: "string", nullable: true },
            banner_key: { type: "string", nullable: true },
            trailer_key: { type: "string", nullable: true },
            stream_manifest_key: { type: "string", nullable: true },
            access_type: {
              type: "string",
              enum: ["free", "premium"],
              example: "free",
            },
            required_coins: { type: "integer", example: 0 },
            seo_title: { type: "string", nullable: true },
            seo_description: { type: "string", nullable: true },
            status: {
              type: "string",
              enum: ["draft", "published", "archived"],
              example: "published",
            },
            published_at: {
              type: "string",
              format: "date-time",
              nullable: true,
            },
            created_by: { type: "string", format: "uuid" },
            updated_by: { type: "string", format: "uuid", nullable: true },
            created_at: { type: "string", format: "date-time" },
            updated_at: { type: "string", format: "date-time" },
            categories: {
              type: "array",
              items: { $ref: "#/components/schemas/Category" },
            },
            genres: {
              type: "array",
              items: { $ref: "#/components/schemas/Genre" },
            },
          },
        },
        CreateContentRequest: {
          type: "object",
          required: ["title", "content_type"],
          properties: {
            title: {
              type: "string",
              maxLength: 255,
              example: "The Last Horizon",
            },
            slug: {
              type: "string",
              maxLength: 255,
              nullable: true,
              description: "Auto-derived from title if omitted.",
            },
            description: { type: "string", nullable: true },
            short_description: {
              type: "string",
              maxLength: 500,
              nullable: true,
            },
            content_type: {
              type: "string",
              enum: ["movie", "series", "documentary", "short"],
            },
            is_series: { type: "boolean", default: false },
            language: { type: "string", maxLength: 50, nullable: true },
            country: { type: "string", maxLength: 100, nullable: true },
            age_rating: { type: "string", maxLength: 20, nullable: true },
            release_date: { type: "string", format: "date", nullable: true },
            duration_seconds: { type: "integer", minimum: 0, nullable: true },
            thumbnail_key: { type: "string", maxLength: 500, nullable: true },
            poster_key: { type: "string", maxLength: 500, nullable: true },
            banner_key: { type: "string", maxLength: 500, nullable: true },
            trailer_key: { type: "string", maxLength: 500, nullable: true },
            stream_manifest_key: {
              type: "string",
              maxLength: 500,
              nullable: true,
            },
            access_type: {
              type: "string",
              enum: ["free", "premium"],
              default: "free",
            },
            required_coins: { type: "integer", minimum: 0, default: 0 },
            seo_title: { type: "string", maxLength: 255, nullable: true },
            seo_description: { type: "string", maxLength: 500, nullable: true },
            status: {
              type: "string",
              enum: ["draft", "published", "archived"],
              default: "draft",
            },
            published_at: {
              type: "string",
              format: "date-time",
              nullable: true,
            },
            category_ids: {
              type: "array",
              items: { type: "string", format: "uuid" },
              default: [],
            },
            genre_ids: {
              type: "array",
              items: { type: "string", format: "uuid" },
              default: [],
            },
          },
        },
        UpdateContentRequest: {
          type: "object",
          minProperties: 1,
          description:
            "Partial update. Any subset of CreateContentRequest fields. Setting status to 'published' auto-fills published_at if missing.",
          properties: {
            title: { type: "string", maxLength: 255 },
            slug: { type: "string", maxLength: 255 },
            description: { type: "string", nullable: true },
            short_description: {
              type: "string",
              maxLength: 500,
              nullable: true,
            },
            content_type: {
              type: "string",
              enum: ["movie", "series", "documentary", "short"],
            },
            is_series: { type: "boolean" },
            language: { type: "string", nullable: true },
            country: { type: "string", nullable: true },
            age_rating: { type: "string", nullable: true },
            release_date: { type: "string", format: "date", nullable: true },
            duration_seconds: { type: "integer", minimum: 0, nullable: true },
            thumbnail_key: { type: "string", nullable: true },
            poster_key: { type: "string", nullable: true },
            banner_key: { type: "string", nullable: true },
            trailer_key: { type: "string", nullable: true },
            stream_manifest_key: { type: "string", nullable: true },
            access_type: { type: "string", enum: ["free", "premium"] },
            required_coins: { type: "integer", minimum: 0 },
            seo_title: { type: "string", nullable: true },
            seo_description: { type: "string", nullable: true },
            status: {
              type: "string",
              enum: ["draft", "published", "archived"],
            },
            published_at: {
              type: "string",
              format: "date-time",
              nullable: true,
            },
            category_ids: {
              type: "array",
              items: { type: "string", format: "uuid" },
            },
            genre_ids: {
              type: "array",
              items: { type: "string", format: "uuid" },
            },
          },
        },
        ContentListResult: {
          type: "object",
          properties: {
            items: {
              type: "array",
              items: { $ref: "#/components/schemas/Content" },
            },
            pagination: {
              type: "object",
              properties: {
                page: { type: "integer", example: 1 },
                limit: { type: "integer", example: 20 },
                total: { type: "integer", example: 5 },
                total_pages: { type: "integer", example: 1 },
              },
            },
          },
        },
        Season: {
          type: "object",
          properties: {
            season_id: { type: "string", format: "uuid" },
            content_id: { type: "string", format: "uuid" },
            season_number: { type: "integer", example: 1 },
            title: { type: "string", nullable: true, example: "Season 1" },
            description: { type: "string", nullable: true },
            thumbnail_key: { type: "string", nullable: true },
            trailer_key: { type: "string", nullable: true },
            release_date: { type: "string", format: "date", nullable: true },
            status: {
              type: "string",
              enum: ["draft", "published", "archived"],
              example: "published",
            },
            created_at: { type: "string", format: "date-time" },
            updated_at: { type: "string", format: "date-time" },
          },
        },
        CreateSeasonRequest: {
          type: "object",
          required: ["season_number"],
          properties: {
            season_number: { type: "integer", minimum: 1, example: 1 },
            title: { type: "string", maxLength: 255, nullable: true },
            description: { type: "string", nullable: true },
            thumbnail_key: { type: "string", maxLength: 500, nullable: true },
            trailer_key: { type: "string", maxLength: 500, nullable: true },
            release_date: { type: "string", format: "date", nullable: true },
            status: {
              type: "string",
              enum: ["draft", "published", "archived"],
              default: "draft",
            },
          },
        },
        UpdateSeasonRequest: {
          type: "object",
          minProperties: 1,
          properties: {
            season_number: { type: "integer", minimum: 1 },
            title: { type: "string", nullable: true },
            description: { type: "string", nullable: true },
            thumbnail_key: { type: "string", nullable: true },
            trailer_key: { type: "string", nullable: true },
            release_date: { type: "string", format: "date", nullable: true },
            status: {
              type: "string",
              enum: ["draft", "published", "archived"],
            },
          },
        },
        Episode: {
          type: "object",
          properties: {
            episode_id: { type: "string", format: "uuid" },
            content_id: { type: "string", format: "uuid" },
            season_id: { type: "string", format: "uuid", nullable: true },
            episode_number: { type: "integer", example: 1 },
            title: { type: "string", example: "Roots" },
            slug: { type: "string", nullable: true },
            description: { type: "string", nullable: true },
            short_description: { type: "string", nullable: true },
            thumbnail_key: { type: "string", nullable: true },
            banner_key: { type: "string", nullable: true },
            video_key: { type: "string", nullable: true },
            stream_manifest_key: { type: "string", nullable: true },
            subtitle_key: { type: "string", nullable: true },
            duration_seconds: {
              type: "integer",
              nullable: true,
              example: 2700,
            },
            release_date: { type: "string", format: "date", nullable: true },
            access_type: { type: "string", enum: ["free", "premium"] },
            required_coins: { type: "integer", example: 0 },
            view_count: { type: "integer", example: 0 },
            status: {
              type: "string",
              enum: ["draft", "published", "archived"],
            },
            created_at: { type: "string", format: "date-time" },
            updated_at: { type: "string", format: "date-time" },
          },
        },
        CreateEpisodeRequest: {
          type: "object",
          required: ["episode_number", "title"],
          properties: {
            season_id: {
              type: "string",
              format: "uuid",
              nullable: true,
              description: "Required for series; omit for movies.",
            },
            episode_number: { type: "integer", minimum: 1, example: 1 },
            title: { type: "string", maxLength: 255, example: "Roots" },
            slug: { type: "string", maxLength: 255, nullable: true },
            description: { type: "string", nullable: true },
            short_description: {
              type: "string",
              maxLength: 500,
              nullable: true,
            },
            thumbnail_key: { type: "string", maxLength: 500, nullable: true },
            banner_key: { type: "string", maxLength: 500, nullable: true },
            video_key: { type: "string", maxLength: 500, nullable: true },
            stream_manifest_key: {
              type: "string",
              maxLength: 500,
              nullable: true,
            },
            subtitle_key: { type: "string", maxLength: 500, nullable: true },
            duration_seconds: { type: "integer", minimum: 0, nullable: true },
            release_date: { type: "string", format: "date", nullable: true },
            access_type: {
              type: "string",
              enum: ["free", "premium"],
              default: "free",
            },
            required_coins: { type: "integer", minimum: 0, default: 0 },
            status: {
              type: "string",
              enum: ["draft", "published", "archived"],
              default: "draft",
            },
          },
        },
        UpdateEpisodeRequest: {
          type: "object",
          minProperties: 1,
          properties: {
            season_id: { type: "string", format: "uuid", nullable: true },
            episode_number: { type: "integer", minimum: 1 },
            title: { type: "string", maxLength: 255 },
            slug: { type: "string", maxLength: 255, nullable: true },
            description: { type: "string", nullable: true },
            short_description: { type: "string", nullable: true },
            thumbnail_key: { type: "string", nullable: true },
            banner_key: { type: "string", nullable: true },
            video_key: { type: "string", nullable: true },
            stream_manifest_key: { type: "string", nullable: true },
            subtitle_key: { type: "string", nullable: true },
            duration_seconds: { type: "integer", minimum: 0, nullable: true },
            release_date: { type: "string", format: "date", nullable: true },
            access_type: { type: "string", enum: ["free", "premium"] },
            required_coins: { type: "integer", minimum: 0 },
            status: {
              type: "string",
              enum: ["draft", "published", "archived"],
            },
          },
        },
      },
    },
    paths: {
      "/api/auth/register": {
        post: {
          tags: ["Auth"],
          summary: "Register a new user",
          description:
            "Create a new user account with email and password. Optionally upload a profile image.",
          requestBody: {
            required: true,
            content: {
              "multipart/form-data": {
                schema: {
                  type: "object",
                  required: ["full_name", "email", "password"],
                  properties: {
                    full_name: { type: "string", example: "Santosh Dahal" },
                    email: {
                      type: "string",
                      format: "email",
                      example: "santosh@example.com",
                    },
                    password: {
                      type: "string",
                      minLength: 8,
                      example: "StrongPass123",
                    },
                    phone: {
                      type: "string",
                      nullable: true,
                      example: "+9779800000000",
                    },
                    country: {
                      type: "string",
                      nullable: true,
                      example: "Nepal",
                    },
                    gender: {
                      type: "string",
                      enum: ["male", "female", "other"],
                      nullable: true,
                    },
                    date_of_birth: {
                      type: "string",
                      format: "date",
                      nullable: true,
                    },
                    avatar: {
                      type: "string",
                      format: "binary",
                      nullable: true,
                      description:
                        "Profile image (JPEG, PNG, GIF, WebP, max 5MB)",
                    },
                  },
                },
              },
            },
          },
          responses: {
            201: {
              description: "User successfully registered",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/AuthResponse" },
                },
              },
            },
            400: {
              description: "Validation error or user already exists",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/create-admin": {
        post: {
          tags: ["Auth"],
          summary: "Create admin user (Admin only)",
          description:
            "Create a new admin account. Only authenticated users with admin role can access this endpoint.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/CreateAdminRequest" },
              },
            },
          },
          responses: {
            201: {
              description: "Admin created successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Admin created successfully",
                      },
                      admin: { $ref: "#/components/schemas/User" },
                    },
                  },
                },
              },
            },
            400: {
              description: "Validation error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized - Invalid or missing token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            403: {
              description: "Forbidden - Only admin can create another admin",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            409: {
              description: "User already exists",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/login": {
        post: {
          tags: ["Auth"],
          summary: "Login user",
          description:
            "Authenticate with email and password to receive JWT access and refresh tokens.",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/LoginRequest" },
              },
            },
          },
          responses: {
            200: {
              description:
                "Login successful - Access and refresh tokens provided",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/AuthResponse" },
                },
              },
            },
            400: {
              description: "Invalid email or password",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            403: {
              description: "Email not verified. OTP sent to user email",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/change-password": {
        post: {
          tags: ["Auth"],
          summary: "Change password",
          description:
            "Change the current user's password and revoke all active sessions.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/ChangePasswordRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Password changed successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Password changed successfully",
                      },
                    },
                  },
                },
              },
            },
            400: {
              description:
                "Validation error, wrong current password, or user not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/logout": {
        post: {
          tags: ["Auth"],
          summary: "Logout current session",
          description:
            "Invalidate the current access token and refresh token session.",
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: "Logged out successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Logged out successfully",
                      },
                    },
                  },
                },
              },
            },
            401: {
              description: "Unauthorized or revoked token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/verify-otp": {
        post: {
          tags: ["Auth"],
          summary: "Verify email OTP",
          description: "Verify email address with the OTP received on email.",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/VerifyOtpRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Email verified successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Email verified successfully",
                      },
                    },
                  },
                },
              },
            },
            400: {
              description: "Invalid OTP, expired OTP, or user not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/resend-otp": {
        post: {
          tags: ["Auth"],
          summary: "Resend email OTP",
          description: "Resend OTP for unverified email accounts.",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/ResendOtpRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "OTP sent successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "OTP sent successfully",
                      },
                    },
                  },
                },
              },
            },
            400: {
              description:
                "User not found, already verified, or email send failed",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/forgot-password": {
        post: {
          tags: ["Auth"],
          summary: "Send forgot password OTP",
          description: "Send OTP to email for password reset.",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/ForgotPasswordRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Password reset OTP process started",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Password reset OTP sent to your email",
                      },
                    },
                  },
                },
              },
            },
            400: {
              description: "Validation error or unsupported auth provider",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/verify-reset-otp": {
        post: {
          tags: ["Auth"],
          summary: "Verify password reset OTP",
          description: "Verify OTP sent for forgot password flow.",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/VerifyResetOtpRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "OTP verified successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "OTP verified successfully",
                      },
                    },
                  },
                },
              },
            },
            400: {
              description: "Invalid OTP, expired OTP, or user not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/reset-password": {
        post: {
          tags: ["Auth"],
          summary: "Reset password using OTP",
          description: "Reset user password after successful OTP verification.",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/ResetPasswordRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Password reset successful",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Password reset successful",
                      },
                    },
                  },
                },
              },
            },
            400: {
              description:
                "Invalid OTP, expired OTP, user not found, or validation error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/google/mobile-login": {
        post: {
          tags: ["Auth"],
          summary: "Google mobile login",
          description:
            "Authenticate a mobile user using Google ID token and return app JWT tokens.",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  $ref: "#/components/schemas/GoogleMobileLoginRequest",
                },
              },
            },
          },
          responses: {
            200: {
              description: "Google login successful",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/AuthResponse" },
                },
              },
            },
            400: {
              description: "Validation or account/provider error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Invalid or expired Google token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/apple/mobile-login": {
        post: {
          tags: ["Auth"],
          summary: "Apple mobile login",
          description:
            "Authenticate a mobile user using Apple identity token and return app JWT tokens.",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  $ref: "#/components/schemas/AppleMobileLoginRequest",
                },
              },
            },
          },
          responses: {
            200: {
              description: "Apple login successful",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/AuthResponse" },
                },
              },
            },
            400: {
              description: "Validation or account/provider error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Invalid or expired Apple token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/refresh": {
        post: {
          tags: ["Auth"],
          summary: "Refresh access token",
          description:
            "Use refresh token to obtain a new access token (valid for 15 minutes).",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/RefreshRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Tokens successfully refreshed",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      tokens: { $ref: "#/components/schemas/AuthTokens" },
                    },
                  },
                },
              },
            },
            401: {
              description: "Invalid or expired refresh token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/auth/me": {
        get: {
          tags: ["Auth"],
          summary: "Get current authenticated user",
          description:
            "Retrieve the profile of the currently authenticated user using JWT token.",
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: "Current user profile retrieved successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      user: { $ref: "#/components/schemas/User" },
                    },
                  },
                },
              },
            },
            401: {
              description: "Unauthorized - Invalid or missing token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/users/me": {
        get: {
          tags: ["Users"],
          summary: "Get my profile",
          description:
            "Retrieve the full profile of the currently authenticated user.",
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: "User profile retrieved successfully",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/UserResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        put: {
          tags: ["Users"],
          summary: "Update my profile",
          description:
            "Update user profile information including optional profile image upload.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "multipart/form-data": {
                schema: {
                  type: "object",
                  properties: {
                    full_name: { type: "string", example: "Updated Name" },
                    phone: { type: "string", nullable: true },
                    country: { type: "string", nullable: true },
                    gender: {
                      type: "string",
                      enum: ["male", "female", "other"],
                      nullable: true,
                    },
                    date_of_birth: {
                      type: "string",
                      format: "date",
                      nullable: true,
                    },
                    avatar: {
                      type: "string",
                      format: "binary",
                      nullable: true,
                      description: "New profile image (max 5MB)",
                    },
                  },
                },
              },
            },
          },
          responses: {
            200: {
              description: "Profile updated successfully",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/UserResponse" },
                },
              },
            },
            400: {
              description: "Validation error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/users/me/{userId}": {
        get: {
          tags: ["Users"],
          summary: "Get user profile by ID",
          description:
            "Retrieve a user profile by user ID. You can only view your own profile unless you are an admin.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "userId",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
              description: "User ID",
            },
          ],
          responses: {
            200: {
              description: "User profile retrieved successfully",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/UserResponse" },
                },
              },
            },
            403: {
              description: "Forbidden - Cannot access other user profiles",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "User not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/users": {
        get: {
          tags: ["Users"],
          summary: "Get all users (Admin only)",
          description:
            "Retrieve a list of all active users. This endpoint requires admin privileges.",
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: "Users list retrieved successfully",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/UsersListResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            403: {
              description: "Forbidden - Admin access required",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/users/{id}": {
        get: {
          tags: ["Users"],
          summary: "Get user by ID (Admin only)",
          description:
            "Retrieve a specific user profile by ID. Admin access required.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
              description: "User ID",
            },
          ],
          responses: {
            200: {
              description: "User details retrieved successfully",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/UserResponse" },
                },
              },
            },
            403: {
              description: "Forbidden - Admin access required",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "User not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        delete: {
          tags: ["Users"],
          summary: "Delete user (Admin only)",
          description:
            "Delete a user account. Admin access required. Cannot delete your own account.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
              description: "User ID to delete",
            },
          ],
          responses: {
            200: {
              description: "User deleted successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "User deleted successfully",
                      },
                    },
                  },
                },
              },
            },
            400: {
              description: "Cannot delete your own account",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            403: {
              description: "Forbidden - Admin access required",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "User not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/khalti/initialize-payment": {
        post: {
          tags: ["Khalti Payments"],
          summary: "Initialize Khalti payment",
          description:
            "Creates an initiated payment record and calls Khalti ePayment initiate API. Requires a valid JWT.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  $ref: "#/components/schemas/KhaltiInitializePaymentRequest",
                },
              },
            },
          },
          responses: {
            200: {
              description: "Payment initialized successfully",
              content: {
                "application/json": {
                  schema: {
                    $ref: "#/components/schemas/KhaltiInitializePaymentResponse",
                  },
                },
              },
            },
            400: {
              description: "Failed to initiate Khalti payment",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized - Missing/invalid token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Coin package not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
          },
        },
      },
      "/api/khalti/complete-khalti-payment": {
        get: {
          tags: ["Khalti Payments"],
          summary: "Complete Khalti payment (callback)",
          description:
            "Verifies the Khalti payment using pidx and updates the payment status. This endpoint is used as Khalti return_url and is not authenticated.",
          parameters: [
            {
              name: "pidx",
              in: "query",
              required: true,
              schema: { type: "string" },
              description: "Khalti payment identifier",
            },
            {
              name: "amount",
              in: "query",
              required: true,
              schema: { type: "string", example: "19900" },
              description: "Amount in paisa (NPR * 100) as returned by Khalti",
            },
            {
              name: "purchase_order_id",
              in: "query",
              required: true,
              schema: { type: "string", format: "uuid" },
              description: "Your internal payment_id used as purchase_order_id",
            },
            {
              name: "transaction_id",
              in: "query",
              required: true,
              schema: { type: "string" },
              description: "Khalti transaction_id",
            },
          ],
          responses: {
            200: {
              description: "Payment successful or already completed",
              content: {
                "application/json": {
                  schema: {
                    oneOf: [
                      {
                        $ref: "#/components/schemas/KhaltiCompletePaymentSuccessResponse",
                      },
                      { $ref: "#/components/schemas/MessageResponse" },
                    ],
                  },
                },
              },
            },
            400: {
              description: "Missing parameters or payment verification failed",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
            404: {
              description: "Payment record not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
            500: {
              description: "Server error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
          },
        },
      },
      "/api/esewa/initialize-payment": {
        post: {
          tags: ["eSewa Payments"],
          summary: "Initialize eSewa payment",
          description:
            "Creates an initiated payment record and returns signed fields for eSewa form submission. Requires a valid JWT.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  $ref: "#/components/schemas/EsewaInitializePaymentRequest",
                },
              },
            },
          },
          responses: {
            200: {
              description: "Payment initialized successfully",
              content: {
                "application/json": {
                  schema: {
                    $ref: "#/components/schemas/EsewaInitializePaymentResponse",
                  },
                },
              },
            },
            400: {
              description: "Validation error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized - Missing/invalid token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Coin package not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
            500: {
              description: "Server error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
          },
        },
      },
      "/api/coin-packages/create": {
        post: {
          tags: ["Coin Packages"],
          summary: "Create a coin package",
          description:
            "Creates a new purchasable coin package. If sort_order is omitted, the next available value is auto-assigned. Uses advisory locking to prevent sort_order conflicts.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  $ref: "#/components/schemas/CreateCoinPackageRequest",
                },
              },
            },
          },
          responses: {
            201: {
              description: "Coin package created successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Coin Package Created Successfully",
                      },
                      result: {
                        $ref: "#/components/schemas/CoinPackage",
                      },
                    },
                  },
                },
              },
            },
            400: {
              description:
                "Validation error - invalid data or invalid sort_order",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: false },
                      message: { type: "string" },
                      code: {
                        type: "string",
                        example: "INVALID_COIN_PACKAGE_DATA",
                      },
                      details: { type: "object", nullable: true },
                    },
                  },
                },
              },
            },
            401: {
              description: "Unauthorized - Missing/invalid token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            409: {
              description: "Sort order already in use",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: false },
                      message: {
                        type: "string",
                        example:
                          "Sort order 1 is already in use. Choose a different sort_order or leave it blank to auto-assign.",
                      },
                      code: {
                        type: "string",
                        example: "COIN_PACKAGE_SORT_ORDER_TAKEN",
                      },
                      details: {
                        type: "object",
                        properties: {
                          field: { type: "string", example: "sort_order" },
                          value: { type: "integer", example: 1 },
                          existingCoinPackageId: {
                            type: "string",
                            format: "uuid",
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
            500: {
              description: "Server error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
          },
        },
      },
      "/api/coin-packages/all": {
        get: {
          tags: ["Coin Packages"],
          summary: "Get all coin packages",
          description:
            "Retrieves all coin packages ordered by sort_order ascending.",
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: "Coin packages fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Coin Packages fetched successfully",
                      },
                      result: {
                        type: "array",
                        items: {
                          $ref: "#/components/schemas/CoinPackage",
                        },
                      },
                    },
                  },
                },
              },
            },
            401: {
              description: "Unauthorized - Missing/invalid token",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            500: {
              description: "Server error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
          },
        },
      },
      "/api/esewa/complete-esewa-payment": {
        get: {
          tags: ["eSewa Payments"],
          summary: "Complete eSewa payment (callback)",
          description:
            "Verifies eSewa callback payload and updates payment status. This endpoint is used as success_url/failure_url and is not authenticated.",
          parameters: [
            {
              name: "data",
              in: "query",
              required: true,
              schema: { type: "string" },
              description:
                "Base64-encoded JSON payload provided by eSewa (contains transaction_uuid, total_amount, signature, etc.)",
            },
          ],
          responses: {
            200: {
              description: "Payment successful or already completed",
              content: {
                "application/json": {
                  schema: {
                    oneOf: [
                      {
                        $ref: "#/components/schemas/EsewaCompletePaymentSuccessResponse",
                      },
                      { $ref: "#/components/schemas/MessageResponse" },
                    ],
                  },
                },
              },
            },
            400: {
              description: "Missing/invalid data or verification failed",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
            404: {
              description: "Payment record not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
            500: {
              description: "Server error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
          },
        },
      },
      "/api/esewa/confirm-sdk-payment": {
        post: {
          tags: ["eSewa Payments"],
          summary: "Confirm eSewa mobile SDK payment",
          description:
            "Verifies the transaction via eSewa status API and credits coins after in-app SDK checkout. Requires JWT.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  required: ["paymentId"],
                  properties: {
                    paymentId: { type: "string", format: "uuid" },
                  },
                },
              },
            },
          },
          responses: {
            200: {
              description: "Payment successful",
              content: {
                "application/json": {
                  schema: {
                    $ref: "#/components/schemas/EsewaCompletePaymentSuccessResponse",
                  },
                },
              },
            },
            400: {
              description: "Bad request",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Payment not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
            500: {
              description: "Server error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/MessageResponse" },
                },
              },
            },
          },
        },
      },
      "/api/wallet/get-coins": {
        get: {
          tags: ["Wallet"],
          summary: "Get current user's coin balance",
          description:
            "Returns the authenticated user's wallet coin balance and metadata.",
          security: [{ bearerAuth: [] }],
          responses: {
            200: {
              description: "User coins fetched successfully",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/WalletCoinsResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            500: {
              description: "Server error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/wallet/payment-history": {
        get: {
          tags: ["Wallet"],
          summary: "Get payment history (admin/user)",
          description:
            "Returns paginated payment history. Admin can view all payments and optionally filter by user_id; normal users can view only their own payments.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              in: "query",
              name: "page",
              schema: { type: "integer", minimum: 1, default: 1 },
              description: "Page number",
              example: 1,
            },
            {
              in: "query",
              name: "limit",
              schema: { type: "integer", minimum: 1, maximum: 100, default: 10 },
              description: "Items per page",
              example: 10,
            },
            {
              in: "query",
              name: "from_date",
              schema: { type: "string", format: "date" },
              description: "Filter records created on/after this date (YYYY-MM-DD)",
              example: "2026-05-01",
            },
            {
              in: "query",
              name: "to_date",
              schema: { type: "string", format: "date" },
              description: "Filter records created on/before this date (YYYY-MM-DD)",
              example: "2026-05-09",
            },
            {
              in: "query",
              name: "status",
              schema: { type: "string" },
              description: "Payment status filter (example: completed, initiated, failed)",
              example: "completed",
            },
            {
              in: "query",
              name: "gateway",
              schema: { type: "string", enum: ["khalti", "esewa"] },
              description: "Payment gateway filter",
              example: "khalti",
            },
            {
              in: "query",
              name: "user_id",
              schema: { type: "string", format: "uuid" },
              description: "Optional user filter (admin only)",
              example: "d7d8d874-8b89-4f16-8447-83df4a7f7134",
            },
          ],
          responses: {
            200: {
              description: "Payment history fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    $ref: "#/components/schemas/WalletPaymentHistoryResponse",
                  },
                  examples: {
                    adminFilteredResult: {
                      summary: "Admin view with user filter",
                      value: {
                        success: true,
                        message: "Payment history fetched successfully",
                        data: {
                          items: [
                            {
                              payment_id: "8f24fb89-f5e7-4dca-9cd5-cf2a6efdd153",
                              amount: "199.00",
                              currency: "NPR",
                              status: "completed",
                              gateway: "khalti",
                              gateway_transaction_id: "khalti_txn_123",
                              gateway_reference: "Khalti Payment Gateway",
                              payment_for: "coin_purchase",
                              coins_credited: 120,
                              paid_at: "2026-05-09T10:15:00.000Z",
                              created_at: "2026-05-09T10:10:00.000Z",
                              user: {
                                user_id: "d7d8d874-8b89-4f16-8447-83df4a7f7134",
                                full_name: "Santosh Dahal",
                                email: "santosh@example.com",
                                phone: "+9779800000000",
                                role: "user",
                              },
                              coin_package: {
                                coin_package_id: "ad98f0e0-b70d-4bc8-8d7f-1f0444afd88d",
                                title: "Starter Pack",
                                coins: 100,
                                bonus_coins: 20,
                                price_amount: "199.00",
                              },
                            },
                          ],
                          pagination: {
                            page: 1,
                            limit: 10,
                            total: 1,
                            total_pages: 1,
                          },
                          filters: {
                            from_date: "2026-05-01",
                            to_date: "2026-05-09",
                            status: "completed",
                            gateway: "khalti",
                            user_id: "d7d8d874-8b89-4f16-8447-83df4a7f7134",
                          },
                        },
                      },
                    },
                    userOwnHistory: {
                      summary: "User view (own payments only)",
                      value: {
                        success: true,
                        message: "Payment history fetched successfully",
                        data: {
                          items: [],
                          pagination: {
                            page: 1,
                            limit: 10,
                            total: 0,
                            total_pages: 0,
                          },
                          filters: {
                            from_date: null,
                            to_date: null,
                            status: null,
                            gateway: null,
                            user_id: "d7d8d874-8b89-4f16-8447-83df4a7f7134",
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
            400: {
              description: "Invalid query parameters (for example invalid dates)",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            500: {
              description: "Server error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/uploads/video": {
        post: {
          tags: ["Video Uploads"],
          summary: "Direct upload + HLS transcode (admin only)",
          description:
            "Uploads a video file, runs instant HLS segmentation (Phase 1) so playback is immediately available, and queues adaptive transcode (Phase 2) as a BullMQ background job. Requires admin JWT.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "multipart/form-data": {
                schema: {
                  type: "object",
                  required: ["video", "content_id"],
                  properties: {
                    video: {
                      type: "string",
                      format: "binary",
                      description:
                        "Video file (mp4/mov/mkv). Max size configurable via UPLOAD_MAX_FILE_SIZE_BYTES (default 50GB).",
                    },
                    content_id: { type: "string", format: "uuid" },
                    season_id: {
                      type: "string",
                      format: "uuid",
                      nullable: true,
                    },
                    episode_id: {
                      type: "string",
                      format: "uuid",
                      nullable: true,
                    },
                    upload_for: {
                      type: "string",
                      enum: [
                        "episode_video",
                        "movie_trailer",
                        "season_trailer",
                      ],
                      default: "episode_video",
                    },
                  },
                },
              },
            },
          },
          responses: {
            201: {
              description:
                "Upload accepted; instant HLS ready, adaptive queued",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/DirectUploadResponse" },
                },
              },
            },
            400: {
              description: "Missing video file or content_id",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            403: {
              description: "Only admin can upload videos",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            500: {
              description: "Server error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/uploads/init": {
        post: {
          tags: ["Video Uploads"],
          summary: "Initiate S3 multipart upload (admin only)",
          description:
            "Creates a VideoUploads record and begins an S3 multipart upload. Returns `upload_id` and `s3_key` for subsequent sign-part calls.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/InitUploadRequest" },
              },
            },
          },
          responses: {
            201: {
              description: "Upload initiated",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/InitUploadResponse" },
                },
              },
            },
            400: {
              description:
                "Validation error, invalid mime type, or file too large",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            403: {
              description: "Only admin can upload videos",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/uploads/sign-part": {
        post: {
          tags: ["Video Uploads"],
          summary: "Generate presigned URL for a multipart part (admin only)",
          description:
            "Returns a short-lived presigned PUT URL for uploading a specific part number directly to S3.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/SignPartRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Presigned URL generated",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/SignPartResponse" },
                },
              },
            },
            400: {
              description: "Invalid payload or upload not in a signable state",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Upload not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/uploads/save-part": {
        post: {
          tags: ["Video Uploads"],
          summary: "Record a successfully uploaded part (admin only)",
          description:
            "Persists the ETag returned by S3 for an uploaded part so it can be used in the final Complete step.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/SavePartRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Part saved or already recorded",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/SavePartResponse" },
                },
              },
            },
            400: {
              description: "Invalid payload or upload in wrong state",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Upload not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/uploads/complete": {
        post: {
          tags: ["Video Uploads"],
          summary: "Complete an S3 multipart upload (admin only)",
          description:
            "Tells S3 to assemble the uploaded parts. Also writes the final s3_key back onto the target Episode/Season/Content record.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/CompleteUploadRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Upload completed",
              content: {
                "application/json": {
                  schema: {
                    $ref: "#/components/schemas/CompleteUploadResponse",
                  },
                },
              },
            },
            400: {
              description: "Invalid payload or upload in wrong state",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Upload not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/uploads/abort": {
        post: {
          tags: ["Video Uploads"],
          summary: "Abort an in-progress multipart upload (admin only)",
          description:
            "Cancels the S3 multipart upload, discards all uploaded parts, and marks the VideoUploads row as `aborted`.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/AbortUploadRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Upload aborted",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/AbortUploadResponse" },
                },
              },
            },
            400: {
              description:
                "Cannot abort upload (already uploaded/aborted) or invalid payload",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Upload not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/uploads/{id}/status": {
        get: {
          tags: ["Video Uploads"],
          summary: "Get upload status (admin only)",
          description:
            "Returns the VideoUploads record for the provided ID including parts_uploaded progress.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
              description: "video_upload_id",
            },
          ],
          responses: {
            200: {
              description: "Upload status retrieved",
              content: {
                "application/json": {
                  schema: {
                    $ref: "#/components/schemas/UploadStatusResponse",
                  },
                },
              },
            },
            404: {
              description: "Upload not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/uploads/{id}/play-url": {
        get: {
          tags: ["Video Uploads"],
          summary: "Get signed CloudFront playback URL (admin only)",
          description:
            "Generates a signed CloudFront URL for a completed upload. Upload status must be `uploaded`.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
              description: "video_upload_id",
            },
          ],
          responses: {
            200: {
              description: "Playback URL generated",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/PlaybackUrlResponse" },
                },
              },
            },
            400: {
              description:
                "Upload not yet completed or missing bucket_name/s3_key",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Upload not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/transcode/{videoUploadId}": {
        post: {
          tags: ["Transcoding"],
          summary: "Trigger HLS transcoding (admin only)",
          description:
            "Starts an FFmpeg job that transcodes a completed upload into adaptive HLS and uploads outputs to S3. Responds immediately; use the status endpoint to poll progress.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "videoUploadId",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            201: {
              description: "Transcoding started",
              content: {
                "application/json": {
                  schema: {
                    $ref: "#/components/schemas/StartTranscodingResponse",
                  },
                },
              },
            },
            400: {
              description:
                "Upload is not in `uploaded` status or missing s3_key",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            403: {
              description: "Only admin can manage transcoding",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Video upload not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            409: {
              description: "Transcoding already in progress for this upload",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/transcode/{videoUploadId}/status": {
        get: {
          tags: ["Transcoding"],
          summary: "Get transcoding job status (admin only)",
          description:
            "Returns the latest TranscodingJobs row for the given video upload including progress percent and output manifest key.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "videoUploadId",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Transcoding status retrieved",
              content: {
                "application/json": {
                  schema: {
                    $ref: "#/components/schemas/TranscodingStatusResponse",
                  },
                },
              },
            },
            404: {
              description: "No transcoding job found for this upload",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/stream/{videoUploadId}/hls": {
        get: {
          tags: ["Streaming"],
          summary: "Get signed HLS playback params (admin only)",
          description:
            "Returns a signed CloudFront URL to the HLS master.m3u8 manifest along with the query params required to load segments. Returns immediately once Phase 1 (instant HLS) output exists; `phase` indicates whether the adaptive transcode has also completed.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "videoUploadId",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "HLS playback params generated",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/HlsPlaybackResponse" },
                },
              },
            },
            404: {
              description:
                "No HLS output found for this upload. Transcode first.",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/content/categories": {
        post: {
          tags: ["Categories"],
          summary: "Create a category",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/CreateCategoryRequest" },
              },
            },
          },
          responses: {
            201: {
              description: "Category created successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Category created successfully",
                      },
                      result: { $ref: "#/components/schemas/Category" },
                    },
                  },
                },
              },
            },
            400: {
              description: "Validation error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        get: {
          tags: ["Categories"],
          summary: "Get all categories",
          description: "Public endpoint - returns all categories.",
          responses: {
            200: {
              description: "Categories fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Categories fetched successfully",
                      },
                      result: {
                        type: "array",
                        items: { $ref: "#/components/schemas/Category" },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      "/api/content/categories/{id}": {
        get: {
          tags: ["Categories"],
          summary: "Get category by ID",
          description: "Public endpoint.",
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Category fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Category" },
                    },
                  },
                },
              },
            },
            404: {
              description: "Category not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        put: {
          tags: ["Categories"],
          summary: "Update a category",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/UpdateCategoryRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Category updated successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Category" },
                    },
                  },
                },
              },
            },
            400: {
              description: "Validation error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Category not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        delete: {
          tags: ["Categories"],
          summary: "Delete a category",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Category deleted successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Category deleted successfully",
                      },
                    },
                  },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Category not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/content/genres": {
        post: {
          tags: ["Genres"],
          summary: "Create a genre",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/CreateGenreRequest" },
              },
            },
          },
          responses: {
            201: {
              description: "Genre created successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Genre created successfully",
                      },
                      result: { $ref: "#/components/schemas/Genre" },
                    },
                  },
                },
              },
            },
            400: {
              description: "Validation error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        get: {
          tags: ["Genres"],
          summary: "Get all genres",
          description: "Public endpoint - returns all genres.",
          responses: {
            200: {
              description: "Genres fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Genres fetched successfully",
                      },
                      result: {
                        type: "array",
                        items: { $ref: "#/components/schemas/Genre" },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      "/api/content/genres/{id}": {
        get: {
          tags: ["Genres"],
          summary: "Get genre by ID",
          description: "Public endpoint.",
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Genre fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Genre" },
                    },
                  },
                },
              },
            },
            404: {
              description: "Genre not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        put: {
          tags: ["Genres"],
          summary: "Update a genre",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/UpdateGenreRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Genre updated successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Genre" },
                    },
                  },
                },
              },
            },
            400: {
              description: "Validation error",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Genre not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        delete: {
          tags: ["Genres"],
          summary: "Delete a genre",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Genre deleted successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Genre deleted successfully",
                      },
                    },
                  },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            404: {
              description: "Genre not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
      },
      "/api/content/contents": {
        post: {
          tags: ["Contents"],
          summary: "Create a content",
          description:
            "Admin only. Creates a movie/series/documentary and optionally attaches categories and genres via category_ids/genre_ids.",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/CreateContentRequest" },
              },
            },
          },
          responses: {
            201: {
              description: "Content created successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Content created successfully",
                      },
                      result: { $ref: "#/components/schemas/Content" },
                    },
                  },
                },
              },
            },
            400: {
              description: "Validation error or unknown category/genre id",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            401: {
              description: "Unauthorized",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            403: {
              description: "Admin privileges required",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
            409: {
              description: "Slug already exists",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        get: {
          tags: ["Contents"],
          summary: "List contents (paginated, filterable)",
          description:
            "Public endpoint. Supports search by title (ILIKE), and filters by content_type, status, access_type, category_id, genre_id.",
          parameters: [
            {
              name: "page",
              in: "query",
              schema: { type: "integer", minimum: 1, default: 1 },
            },
            {
              name: "limit",
              in: "query",
              schema: {
                type: "integer",
                minimum: 1,
                maximum: 100,
                default: 20,
              },
            },
            {
              name: "search",
              in: "query",
              schema: { type: "string" },
              description: "Case-insensitive partial match on title",
            },
            {
              name: "content_type",
              in: "query",
              schema: {
                type: "string",
                enum: ["movie", "series", "documentary", "short"],
              },
            },
            {
              name: "status",
              in: "query",
              schema: {
                type: "string",
                enum: ["draft", "published", "archived"],
              },
            },
            {
              name: "access_type",
              in: "query",
              schema: { type: "string", enum: ["free", "premium"] },
            },
            {
              name: "category_id",
              in: "query",
              schema: { type: "string", format: "uuid" },
            },
            {
              name: "genre_id",
              in: "query",
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Contents fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: {
                        $ref: "#/components/schemas/ContentListResult",
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      "/api/content/contents/{id}": {
        get: {
          tags: ["Contents"],
          summary: "Get content by ID",
          description:
            "Public endpoint. Returns the content along with its categories, genres, seasons, and episodes.",
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Content fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Content" },
                    },
                  },
                },
              },
            },
            404: {
              description: "Content not found",
              content: {
                "application/json": {
                  schema: { $ref: "#/components/schemas/ErrorResponse" },
                },
              },
            },
          },
        },
        put: {
          tags: ["Contents"],
          summary: "Update a content",
          description:
            "Admin only. Partial update. If category_ids or genre_ids are provided, the relations are replaced. Setting status to 'published' auto-fills published_at if missing.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/UpdateContentRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Content updated successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Content" },
                    },
                  },
                },
              },
            },
            400: { description: "Validation error" },
            401: { description: "Unauthorized" },
            403: { description: "Admin privileges required" },
            404: { description: "Content not found" },
            409: { description: "Slug already exists" },
          },
        },
        delete: {
          tags: ["Contents"],
          summary: "Delete a content",
          description:
            "Admin only. Cascade deletes all episodes, seasons, and category/genre links inside a transaction.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Content deleted successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: {
                        type: "string",
                        example: "Content deleted successfully",
                      },
                    },
                  },
                },
              },
            },
            401: { description: "Unauthorized" },
            403: { description: "Admin privileges required" },
            404: { description: "Content not found" },
          },
        },
      },
      "/api/content/contents/{contentId}/seasons": {
        post: {
          tags: ["Seasons"],
          summary: "Create a season under a content",
          description:
            "Admin only. season_number must be unique per content. Recomputes Contents.total_seasons and forces is_series=true.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "contentId",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/CreateSeasonRequest" },
              },
            },
          },
          responses: {
            201: {
              description: "Season created successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Season" },
                    },
                  },
                },
              },
            },
            400: { description: "Validation error" },
            401: { description: "Unauthorized" },
            403: { description: "Admin privileges required" },
            404: { description: "Content not found" },
            409: {
              description: "Season number already exists for this content",
            },
          },
        },
        get: {
          tags: ["Seasons"],
          summary: "List seasons for a content",
          description: "Public endpoint. Sorted by season_number ASC.",
          parameters: [
            {
              name: "contentId",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Seasons fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: {
                        type: "array",
                        items: { $ref: "#/components/schemas/Season" },
                      },
                    },
                  },
                },
              },
            },
            404: { description: "Content not found" },
          },
        },
      },
      "/api/content/seasons/{id}": {
        get: {
          tags: ["Seasons"],
          summary: "Get season by ID",
          description: "Public endpoint. Includes the season's episodes.",
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Season fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Season" },
                    },
                  },
                },
              },
            },
            404: { description: "Season not found" },
          },
        },
        put: {
          tags: ["Seasons"],
          summary: "Update a season",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/UpdateSeasonRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Season updated successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Season" },
                    },
                  },
                },
              },
            },
            400: { description: "Validation error" },
            401: { description: "Unauthorized" },
            403: { description: "Admin privileges required" },
            404: { description: "Season not found" },
            409: {
              description: "Season number already exists for this content",
            },
          },
        },
        delete: {
          tags: ["Seasons"],
          summary: "Delete a season",
          description:
            "Admin only. Cascade deletes all episodes in the season and recomputes Contents.total_seasons / total_episodes.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: { description: "Season deleted successfully" },
            401: { description: "Unauthorized" },
            403: { description: "Admin privileges required" },
            404: { description: "Season not found" },
          },
        },
      },
      "/api/content/contents/{contentId}/episodes": {
        post: {
          tags: ["Episodes"],
          summary: "Create an episode under a content",
          description:
            "Admin only. season_id is required for series and must belong to the same content. episode_number must be unique within (content_id, season_id).",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "contentId",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/CreateEpisodeRequest" },
              },
            },
          },
          responses: {
            201: {
              description: "Episode created successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Episode" },
                    },
                  },
                },
              },
            },
            400: {
              description:
                "Validation error or season_id does not belong to this content",
            },
            401: { description: "Unauthorized" },
            403: { description: "Admin privileges required" },
            404: { description: "Content not found" },
            409: {
              description:
                "Episode number already exists for this (content, season)",
            },
          },
        },
        get: {
          tags: ["Episodes"],
          summary: "List episodes for a content",
          description: "Public endpoint. Sorted by season_id, episode_number.",
          parameters: [
            {
              name: "contentId",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Episodes fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: {
                        type: "array",
                        items: { $ref: "#/components/schemas/Episode" },
                      },
                    },
                  },
                },
              },
            },
            404: { description: "Content not found" },
          },
        },
      },
      "/api/content/seasons/{seasonId}/episodes": {
        get: {
          tags: ["Episodes"],
          summary: "List episodes for a season",
          description: "Public endpoint. Sorted by episode_number.",
          parameters: [
            {
              name: "seasonId",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Episodes fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: {
                        type: "array",
                        items: { $ref: "#/components/schemas/Episode" },
                      },
                    },
                  },
                },
              },
            },
            404: { description: "Season not found" },
          },
        },
      },
      "/api/content/episodes/{id}": {
        get: {
          tags: ["Episodes"],
          summary: "Get episode by ID",
          description: "Public endpoint.",
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: {
              description: "Episode fetched successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Episode" },
                    },
                  },
                },
              },
            },
            404: { description: "Episode not found" },
          },
        },
        put: {
          tags: ["Episodes"],
          summary: "Update an episode",
          description:
            "Admin only. Moving an episode to a new season requires the new season to belong to the same content.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: { $ref: "#/components/schemas/UpdateEpisodeRequest" },
              },
            },
          },
          responses: {
            200: {
              description: "Episode updated successfully",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      success: { type: "boolean", example: true },
                      message: { type: "string" },
                      result: { $ref: "#/components/schemas/Episode" },
                    },
                  },
                },
              },
            },
            400: { description: "Validation error" },
            401: { description: "Unauthorized" },
            403: { description: "Admin privileges required" },
            404: { description: "Episode not found" },
            409: {
              description:
                "Episode number already exists for this (content, season)",
            },
          },
        },
        delete: {
          tags: ["Episodes"],
          summary: "Delete an episode",
          description:
            "Admin only. Recomputes Contents.total_episodes after deletion.",
          security: [{ bearerAuth: [] }],
          parameters: [
            {
              name: "id",
              in: "path",
              required: true,
              schema: { type: "string", format: "uuid" },
            },
          ],
          responses: {
            200: { description: "Episode deleted successfully" },
            401: { description: "Unauthorized" },
            403: { description: "Admin privileges required" },
            404: { description: "Episode not found" },
          },
        },
      },
    },
  };
};

const setupSwagger = (app) => {
  const swaggerSpec = buildOpenApiSpec();

  const swaggerOptions = {
    swaggerOptions: {
      persistAuthorization: true,
      displayOperationId: false,
      filter: true,
      showRequestHeaders: true,
    },
  };

  app.use(
    "/api-docs",
    swaggerUi.serve,
    swaggerUi.setup(swaggerSpec, swaggerOptions),
  );
  app.get("/api-docs.json", (req, res) => {
    res.setHeader("Content-Type", "application/json");
    res.send(swaggerSpec);
  });
};

module.exports = {
  setupSwagger,
};
