$(lib_binaries)  += libgomp
ifeq ($(with_lib64gomp),yes)
  $(lib_binaries)  += lib64gomp
endif
ifeq ($(with_lib32gomp),yes)
  $(lib_binaries)	+= lib32gomp
endif
ifeq ($(with_libn32gomp),yes)
  $(lib_binaries)	+= libn32gomp
endif

define __do_gomp
	dh_testdir
	dh_testroot
	mv $(install_stamp) $(install_stamp)-tmp

	rm -rf $(d_l) $(d_d)
	dh_installdirs -p$(p_l) $(2)
	DH_COMPAT=2 dh_movefiles -p$(p_l) $(2)/libgomp.so.*

	debian/dh_doclink -p$(p_l) $(p_base)
	debian/dh_doclink -p$(p_d) $(p_base)

	dh_strip -p$(p_l) --dbg-package=$(p_d)
	dh_compress -p$(p_l) -p$(p_d)
	dh_fixperms -p$(p_l) -p$(p_d)
	dh_makeshlibs -p$(p_l)
	$(call cross_mangle_shlibs,$(p_l))
	$(cross_shlibdeps) dh_shlibdeps -p$(p_l)
	$(call cross_mangle_substvars,$(p_l))
	dh_gencontrol -p$(p_l) -p$(p_d)	\
		-- -v$(DEB_VERSION) $(common_substvars)
	$(call cross_mangle_control,$(p_l))
	dh_installdeb -p$(p_l) -p$(p_d)
	dh_md5sums -p$(p_l) -p$(p_d)
	dh_builddeb -p$(p_l) -p$(p_d)

	trap '' 1 2 3 15; touch $@; mv $(install_stamp)-tmp $(install_stamp)
endef

# ----------------------------------------------------------------------

do_gomp = $(call __do_gomp,lib$(1)gomp$(GOMP_SONAME),$(usr_lib$(1)))

$(binary_stamp)-libgomp: $(install_stamp)
	$(call do_gomp,)

$(binary_stamp)-lib64gomp: $(install_stamp)
	$(call do_gomp,64)

$(binary_stamp)-lib32gomp: $(install_stamp)
	$(call do_gomp,32)

$(binary_stamp)-libn32gomp: $(install_stamp)
	$(call do_gomp,n32)
