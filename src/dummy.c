#include <stdio.h>

void JVM_RawMonitorCreate() {
    fprintf(stderr, "We should never reach here (JVM_RawMonitorCreate)\n");
}

void JVM_RawMonitorDestroy() {
    fprintf(stderr, "We should never reach here (JVM_RawMonitorDestroy)\n");
}

void JVM_RawMonitorEnter() {
    fprintf(stderr, "We should never reach here (JVM_RawMonitorEnter)\n");
}

void JVM_RawMonitorExit() {
    fprintf(stderr, "We should never reach here (JVM_RawMonitorExit)\n");
}

void JVM_NativePath() {
    fprintf(stderr, "We should never reach here (JVM_nativePath)\n");
}

void JVM_IsUseContainerSupport() {
    fprintf(stderr, "We should never reach here (JVM_IsUseContainerSupport)\n");
}

 void JVM_RaiseSignal() {
    fprintf(stderr, "We should never reach here (JVM_RaiseSignal)\n");
 }
