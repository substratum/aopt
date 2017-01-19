/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <utils/String8.h>
#include <gtest/gtest.h>

#include "AoptConfig.h"
#include "ConfigDescription.h"
#include "SdkConstants.h"
#include "TestHelper.h"

using android::String8;

static ::testing::AssertionResult TestParse(const String8& input, ConfigDescription* config=NULL) {
    if (AoptConfig::parse(String8(input), config)) {
        return ::testing::AssertionSuccess() << input << " was successfully parsed";
    }
    return ::testing::AssertionFailure() << input << " could not be parsed";
}

static ::testing::AssertionResult TestParse(const char* input, ConfigDescription* config=NULL) {
    return TestParse(String8(input), config);
}

TEST(AoptConfigTest, ParseFailWhenQualifiersAreOutOfOrder) {
    EXPECT_FALSE(TestParse("en-sw600dp-ldrtl"));
    EXPECT_FALSE(TestParse("land-en"));
    EXPECT_FALSE(TestParse("hdpi-320dpi"));
}

TEST(AoptConfigTest, ParseFailWhenQualifiersAreNotMatched) {
    EXPECT_FALSE(TestParse("en-sw600dp-ILLEGAL"));
}

TEST(AoptConfigTest, ParseFailWhenQualifiersHaveTrailingDash) {
    EXPECT_FALSE(TestParse("en-sw600dp-land-"));
}

TEST(AoptConfigTest, ParseBasicQualifiers) {
    ConfigDescription config;
    EXPECT_TRUE(TestParse("", &config));
    EXPECT_EQ(String8(""), config.toString());

    EXPECT_TRUE(TestParse("fr-land", &config));
    EXPECT_EQ(String8("fr-land"), config.toString());

    EXPECT_TRUE(TestParse("mcc310-pl-sw720dp-normal-long-port-night-"
                "xhdpi-keyssoft-qwerty-navexposed-nonav", &config));
    EXPECT_EQ(String8("mcc310-pl-sw720dp-normal-long-port-night-"
                "xhdpi-keyssoft-qwerty-navexposed-nonav-v13"), config.toString());
}

TEST(AoptConfigTest, ParseLocales) {
    ConfigDescription config;
    EXPECT_TRUE(TestParse("en-rUS", &config));
    EXPECT_EQ(String8("en-rUS"), config.toString());
}

TEST(AoptConfigTest, ParseQualifierAddedInApi13) {
    ConfigDescription config;
    EXPECT_TRUE(TestParse("sw600dp", &config));
    EXPECT_EQ(String8("sw600dp-v13"), config.toString());

    EXPECT_TRUE(TestParse("sw600dp-v8", &config));
    EXPECT_EQ(String8("sw600dp-v13"), config.toString());
}

TEST(AoptConfigTest, TestParsingOfCarAttribute) {
    ConfigDescription config;
    EXPECT_TRUE(TestParse("car", &config));
    EXPECT_EQ(android::ResTable_config::UI_MODE_TYPE_CAR, config.uiMode);
}

TEST(AoptConfigTest, TestParsingRoundQualifier) {
    ConfigDescription config;
    EXPECT_TRUE(TestParse("round", &config));
    EXPECT_EQ(android::ResTable_config::SCREENROUND_YES,
              config.screenLayout2 & android::ResTable_config::MASK_SCREENROUND);
    EXPECT_EQ(SDK_MNC, config.sdkVersion);
    EXPECT_EQ(String8("round-v23"), config.toString());

    EXPECT_TRUE(TestParse("notround", &config));
    EXPECT_EQ(android::ResTable_config::SCREENROUND_NO,
              config.screenLayout2 & android::ResTable_config::MASK_SCREENROUND);
    EXPECT_EQ(SDK_MNC, config.sdkVersion);
    EXPECT_EQ(String8("notround-v23"), config.toString());
}
