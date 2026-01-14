import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.k8s.apimachinery.pkg.apis.meta.v1 as metav1

# ==============================================================================
# Unit tests for AtlasOperator XRD
# ==============================================================================

_items = [
    # ==========================================================================
    # Test 1: Minimal input renders Helm release
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "minimal-renders-helm-release"
        spec = {
            compositionPath = "apis/atlasoperators/composition.yaml"
            xrdPath = "apis/atlasoperators/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "AtlasOperator"
                metadata.name = "test-atlas-operator"
                spec = {
                    clusterName = "test-cluster"
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "test-atlas-operator"
                }
            ]
        }
    }

    # ==========================================================================
    # Test 2: Custom labels are applied and merged with defaults
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "custom-labels-merged-with-defaults"
        spec = {
            compositionPath = "apis/atlasoperators/composition.yaml"
            xrdPath = "apis/atlasoperators/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "AtlasOperator"
                metadata.name = "labeled-atlas-operator"
                spec = {
                    clusterName = "test-cluster"
                    labels = {
                        team = "platform"
                        environment = "staging"
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata = {
                        name = "labeled-atlas-operator"
                        labels = {
                            "hops.ops.com.ai/managed" = "true"
                            "hops.ops.com.ai/atlasoperator" = "labeled-atlas-operator"
                            team = "platform"
                            environment = "staging"
                        }
                    }
                }
            ]
        }
    }

    # ==========================================================================
    # Test 3: overrideAllValues replaces defaults
    # ==========================================================================
    metav1alpha1.CompositionTest {
        metadata.name = "override-all-values"
        spec = {
            compositionPath = "apis/atlasoperators/composition.yaml"
            xrdPath = "apis/atlasoperators/definition.yaml"
            timeoutSeconds = 60
            validate = False
            xr = {
                apiVersion = "helm.hops.ops.com.ai/v1alpha1"
                kind = "AtlasOperator"
                metadata.name = "override-test"
                spec = {
                    clusterName = "my-cluster"
                    helm.atlasOperator.overrideAllValues = {
                        fullnameOverride = "custom-atlas-operator"
                        prewarmDevDB = False
                    }
                }
            }
            assertResources = [
                {
                    apiVersion = "helm.m.crossplane.io/v1beta1"
                    kind = "Release"
                    metadata.name = "override-test"
                    spec.forProvider.values = {
                        fullnameOverride = "custom-atlas-operator"
                        prewarmDevDB = False
                    }
                }
            ]
        }
    }
]

items = _items
