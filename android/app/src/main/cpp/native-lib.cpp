#include <jni.h>
#include <cstdlib>
#include <cstring>
#include <vector>
#include "node.h"

extern "C" JNIEXPORT jint JNICALL
Java_com_example_tablet_1vscode_MainActivity_startNodeWithArguments(
    JNIEnv* env, jobject, jobjectArray arguments) {
  const jsize count = env->GetArrayLength(arguments);
  std::vector<char*> argv;
  argv.reserve(static_cast<size_t>(count));
  std::vector<std::vector<char>> storage;
  storage.reserve(static_cast<size_t>(count));

  for (jsize i = 0; i < count; ++i) {
    auto value = static_cast<jstring>(env->GetObjectArrayElement(arguments, i));
    if (value == nullptr) return 2;
    const char* utf = env->GetStringUTFChars(value, nullptr);
    if (utf == nullptr) return 3;
    storage.emplace_back(utf, utf + std::strlen(utf) + 1);
    argv.push_back(storage.back().data());
    env->ReleaseStringUTFChars(value, utf);
    env->DeleteLocalRef(value);
  }
  return node::Start(static_cast<int>(argv.size()), argv.data());
}
