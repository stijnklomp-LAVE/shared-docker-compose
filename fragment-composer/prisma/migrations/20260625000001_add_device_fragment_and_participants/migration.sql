-- Add new enums for participant tracking
CREATE TYPE "ParticipantRole" AS ENUM ('SOURCE', 'TARGET');
CREATE TYPE "ParticipantStatus" AS ENUM ('PENDING', 'ACCEPTED', 'REJECTED', 'CANCELLED', 'COMPLETED');

-- Migrate TransferRequestStatus enum from old values (PENDING, ACCEPTED, REJECTED, EXPIRED, COMPLETED)
-- to new values (PENDING, ACTIVE, COMPLETED, DELETED, EXPIRED)
CREATE TYPE "TransferRequestStatus_new" AS ENUM ('PENDING', 'ACTIVE', 'COMPLETED', 'DELETED', 'EXPIRED');
ALTER TABLE "TransferRequest" ALTER COLUMN "status" TYPE "TransferRequestStatus_new" USING "status"::text::"TransferRequestStatus_new";
DROP TYPE "TransferRequestStatus";
ALTER TYPE "TransferRequestStatus_new" RENAME TO "TransferRequestStatus";

-- Add creatorDeviceId column to Fragment
ALTER TABLE "Fragment" ADD COLUMN "creatorDeviceId" TEXT;

-- Create DeviceFragment table
CREATE TABLE "DeviceFragment" (
    "id" TEXT NOT NULL,
    "deviceId" TEXT NOT NULL,
    "fragmentId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updaterDeviceId" TEXT,
    CONSTRAINT "DeviceFragment_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "DeviceFragment_deviceId_fragmentId_key" ON "DeviceFragment"("deviceId", "fragmentId");

ALTER TABLE "DeviceFragment" ADD CONSTRAINT "DeviceFragment_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "Device"("deviceId") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "DeviceFragment" ADD CONSTRAINT "DeviceFragment_fragmentId_fkey" FOREIGN KEY ("fragmentId") REFERENCES "Fragment"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Drop old TransferRequest inline device relations
ALTER TABLE "TransferRequest" DROP CONSTRAINT IF EXISTS "TransferRequest_sourceDeviceId_fkey";
ALTER TABLE "TransferRequest" DROP CONSTRAINT IF EXISTS "TransferRequest_targetDeviceId_fkey";
ALTER TABLE "TransferRequest" DROP COLUMN IF EXISTS "sourceDeviceId";
ALTER TABLE "TransferRequest" DROP COLUMN IF EXISTS "targetDeviceId";
ALTER TABLE "TransferRequest" DROP COLUMN IF EXISTS "acceptedAt";
ALTER TABLE "TransferRequest" DROP COLUMN IF EXISTS "completedAt";

-- Create TransferRequestParticipant table
CREATE TABLE "TransferRequestParticipant" (
    "id" TEXT NOT NULL,
    "transferRequestId" TEXT NOT NULL,
    "deviceId" TEXT NOT NULL,
    "role" "ParticipantRole" NOT NULL,
    "status" "ParticipantStatus" NOT NULL DEFAULT 'PENDING',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "TransferRequestParticipant_pkey" PRIMARY KEY ("id")
);

ALTER TABLE "TransferRequestParticipant" ADD CONSTRAINT "TransferRequestParticipant_transferRequestId_fkey" FOREIGN KEY ("transferRequestId") REFERENCES "TransferRequest"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "TransferRequestParticipant" ADD CONSTRAINT "TransferRequestParticipant_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "Device"("deviceId") ON DELETE CASCADE ON UPDATE CASCADE;
