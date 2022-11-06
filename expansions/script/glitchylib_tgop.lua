GFILTER_TABLE = {aux.dncheck}
GFILTER_DIFFERENT_NAMES = 1

ACTION_TABLE = {[CATEGORY_DESTROY]=function(g) Duel.Destroy(g,REASON_EFFECT) end}

CONJUNCTION_AND_IF_YOU_DO		=	1
CONJUNCTION_THEN				=	2
CONJUNCTION_ALSO				=	3
CONJUNCTION_ALSO_AFTER_THAT		=	4

--Complex Operation Builder
function Auxiliary.CreateOperation(...)
	local x={...}
	return	function(e,tp,eg,ep,ev,re,r,rp)
				for i,op in ipairs(x) do
					if type(op)=="function" then
						local conj = (i>2 and type(x[i-1])=="number") and x[i-1] or nil
						local res,rct,rchk=op(e,tp,eg,ep,ev,re,r,rp,conj)
						if (conj==CONJUNCTION_AND_IF_YOU_DO or conj==CONJUNCTION_THEN)
							and ((type(rchk)~="nil" and not rchk) or (type(rct)=="nil" and type(rchk)=="nil" and not res)) then
							return
						end
					end
				end
			end
end
function Auxiliary.CheckSequentiality(conj)
	if conj and (conj==CONJUNCTION_THEN or conj==CONJUNCTION_ALSO_AFTER_THAT) then
		Duel.BreakEffect()
	end
end

--Target/Operation functions and filters
--Simple Target
function Auxiliary.Check(check,info,...)
	local x={...}
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return (not check or check(e,tp,eg,ep,ev,re,r,rp)) end
				if info then
					info(nil,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(nil,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end
function Auxiliary.CostCheck(check,cost,info,...)
	local x={...}
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					if e:GetLabel()~=1 then return false end
					e:SetLabel(0)
					return not check or check(e,tp,eg,ep,ev,re,r,rp)
				end
				e:SetLabel(0)
				if cost then
					cost(e,tp,eg,ep,ev,re,r,rp)
				end
				if info then
					info(nil,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(nil,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end
function Auxiliary.LabelCheck(labelcheck,check,info,...)
	local x={...}
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local l=e:GetLabel()
					local lchk = (l==1) or labelcheck(e,tp,eg,ep,ev,re,r,rp)
					e:SetLabel(0)
					return lchk and (not check or check(e,tp,eg,ep,ev,re,r,rp))
				end
				e:SetLabel(0)
				if info then
					info(nil,e,tp,eg,ep,ev,re,r,rp)
					if #x>0 then
						for _,extrainfo in ipairs(x) do
							extrainfo(nil,e,tp,eg,ep,ev,re,r,rp)
						end
					end
				end
			end
end
function Auxiliary.Target(f,loc1,loc2,min,max,exc,check,info,prechk,necrovalley,...)
	local x={...}
	if not f then f=aux.TRUE end
	if not min then min=1 end
	if not max then max=min end
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	local locs = (loc1&(~loc2))|loc2
	
	if locs&LOCATION_GRAVE>0 and necrovalley then
		f=aux.NecroValleyFilter(f)
	end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local exc= (aux.GetValueType(exc)=="boolean" and exc) and e:GetHandler() or (exc) and exc or nil
				if chkc then
					local plchk=(loc1~=0 and chkc:IsControler(tp) and chkc:IsLocation(loc1) or loc2~=0 and chkc:IsControler(1-tp) and chkc:IsLocation(loc2))
					return plchk and (not f or f(chkc,e,tp,eg,ep,ev,re,r,rp,chk))
				end
				if chk==0 then
					if prechk then prechk(e,tp,eg,ep,ev,re,r,rp) end
					return ((not check or check(e,tp,eg,ep,ev,re,r,rp)) and Duel.IsExistingTarget(f,tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp,chk))
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
				local g=Duel.SelectTarget(tp,f,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp,chk)
				if info then
					if type(info)=="function" then
						info(g,e,tp,eg,ep,ev,re,r,rp)
					elseif type(info)=="table" then
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetCustomOperationInfo(0,info[1],g,#g,p,locs,info[2])
					else
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetOperationInfo(0,info,g,#g,p,locs)
					end
				end
				if #x>0 then
				
					for _,extrainfo in ipairs(x) do
						if type(extrainfo)=="function" then
							extrainfo(g,e,tp,eg,ep,ev,re,r,rp)
						elseif type(extrainfo)=="table" then
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetCustomOperationInfo(0,extrainfo[1],g,#g,p,locs,extrainfo[2])
						else
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetOperationInfo(0,extrainfo,g,#g,p,locs)
						end
					end
				end
				return g
			end
end
function Auxiliary.TargetUpToTheNumberOfCards(f,loc1,loc2,min,exc,gf,gloc1,gloc2,gexc,check,info,prechk,necrovalley,...)
	local x={...}
	if not f then f=aux.TRUE end
	if not min then min=1 end
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	local locs = (loc1&(~loc2))|loc2
	
	if locs&LOCATION_GRAVE>0 and necrovalley then
		f=aux.NecroValleyFilter(f)
	end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk,chkc)
				local exc= (aux.GetValueType(exc)=="boolean" and exc) and e:GetHandler() or (exc) and exc or nil
				if chkc then
					local plchk=(loc1~=0 and chkc:IsControler(tp) and chkc:IsLocation(loc1) or loc2~=0 and chkc:IsControler(1-tp) and chkc:IsLocation(loc2))
					return plchk and (not f or f(chkc,e,tp,eg,ep,ev,re,r,rp,chk))
				end
				local sg=Duel.Group(gf,tp,gloc1,gloc2,gexc,e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					if prechk then prechk(e,tp,eg,ep,ev,re,r,rp) end
					return (not check or check(e,tp,eg,ep,ev,re,r,rp)) and Duel.IsExistingTarget(f,tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp,chk)
						and #sg>=min
				end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
				local g=Duel.SelectTarget(tp,f,tp,loc1,loc2,min,#sg,exc,e,tp,eg,ep,ev,re,r,rp,chk)
				if info then
					if type(info)=="function" then
						info(g,e,tp,eg,ep,ev,re,r,rp)
					elseif type(info)=="table" then
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetCustomOperationInfo(0,info[1],g,#g,p,locs,info[2])
					else
						local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
						Duel.SetOperationInfo(0,info,g,#g,p,locs)
					end
				end
				if #x>0 then
				
					for _,extrainfo in ipairs(x) do
						if type(extrainfo)=="function" then
							extrainfo(g,e,tp,eg,ep,ev,re,r,rp)
						elseif type(extrainfo)=="table" then
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetCustomOperationInfo(0,extrainfo[1],g,#g,p,locs,extrainfo[2])
						else
							local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
							Duel.SetOperationInfo(0,extrainfo,g,#g,p,locs)
						end
					end
				end
				return g
			end
end

function Auxiliary.TargetOperation(op,f,hardchk,prechk,postchk)
	if type(op)=="number" then
		op=ACTION_TABLE[op]
	end
	if not hardchk then
		if type(f)=="function" then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if prechk and not prechk(e,tp,eg,ep,ev,re,r,rp) then return end
						local g=Duel.GetTargetCards():Filter(f,nil,e,tp,eg,ep,ev,re,r,rp)
						if #g>0 and (not postchk or postchk(g,e,tp,eg,ep,ev,re,r,rp)) then
							aux.CheckSequentiality(conj)
							local ct,chk=op(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,chk
						end
						return g,0
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if prechk and not prechk(e,tp,eg,ep,ev,re,r,rp) then return end
						local g=Duel.GetTargetCards()
						if #g>0 and (not postchk or postchk(g,e,tp,eg,ep,ev,re,r,rp)) then
							aux.CheckSequentiality(conj)
							local ct,chk=op(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,chk
						end
						return g,0
					end
		end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if prechk and not prechk(e,tp,eg,ep,ev,re,r,rp) then return end
						local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
						for tc in aux.Next(g) do
							if not tc:IsRelateToChain() or (f and not f(tc,e,tp,eg,ep,ev,re,r,rp)) then
								return
							end
						end	
						if #g>0 and (not postchk or postchk(g,e,tp,eg,ep,ev,re,r,rp)) then
							aux.CheckSequentiality(conj)
							local ct,chk=op(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,chk
						end
						return g,0
					end
	end
end

-----------------------------------------------------------------------
--Infos
function Auxiliary.Info(ctg,ct,p,v)
	return	function(_,e,tp)
				local p=(p>1) and p or (p==0) and tp or (p==1) and 1-tp 
				return Duel.SetOperationInfo(0,ctg,nil,ct,p,v)
			end
end
function Auxiliary.DamageInfo(p,v)
	return	function(_,e,tp)
				return Auxiliary.Info(CATEGORY_DAMAGE,0,p,v)
			end
end
function Auxiliary.HandlerInfo(ctg,ct,p,v,custom)
	if not custom then
		return	function(_,e,tp)
					local p=(p>1) and p or (p==0) and tp or (p==1) and 1-tp 
					return Duel.SetOperationInfo(0,ctg,e:GetHandler(),ct,p,v)
				end
	else
		return	function(_,e,tp)
					local p=(p>1) and p or (p==0) and tp or (p==1) and 1-tp 
					return Duel.SetCustomOperationInfo(0,ctg,e:GetHandler(),ct,p,v,custom)
				end
	end
end
function Auxiliary.GroupInfo(ctg)
	return	function(g)
				return Duel.SetOperationInfo(0,ctg,g,#g,0,0)
			end
end
function Auxiliary.SelfInfo(ctg)
	return	function(_,e)
				return Duel.SetOperationInfo(0,ctg,e:GetHandler(),1,0,0)
			end
end

-----------------------------------------------------------------------
function Auxiliary.CardMovementOperationTemplate(fn,action_filter,loc,subject,loc1,loc2,min,max,exc)
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		if (loc1|loc2)&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=Duel.SelectMatchingCard(tp,action_filter(subject),tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) then
							Duel.HintSelection(g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED))
						end
						local ct=fn(g,e,tp,eg,ep,ev,re,r,rp)
						return g,ct,aux.PLChk(g,nil,loc)
					end
					return g,0
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						aux.CheckSequentiality(conj)
						local ct=fn(c,e,tp,eg,ep,ev,re,r,rp)
						return c,1,aux.PLChk(c,nil,loc)
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							local chk=0
							local ct=fn(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,aux.PLChk(g,nil,loc)
						end
			return aux.TargetOperation(op)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if (loc1|loc2)&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(action_filter(truesub),tp,loc1,loc2,exc)
						if #g<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							if sg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) then
								Duel.HintSelection(sg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED))
							end
							local ct=fn(sg,e,tp,eg,ep,ev,re,r,rp)
							return sg,ct,aux.PLChk(sg,nil,loc)
						end
						return sg,0
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							local ct=fn(g,e,tp,eg,ep,ev,re,r,rp)
							return g,ct,aux.PLChk(g,nil,loc)
						end
			return aux.TargetOperation(op,f,hardchk)
		end
	end
end
function Auxiliary.CardsInteractionOperationTemplate(fn,action_filter,subject,loc1,loc2,min,max,exc,subject2,action_filter2,loc3,loc4,exc2)
	local check,sel
	if type(subject2)=="function" then
		subject2=action_filter2(subject2)
		check=	function(g,e,tp,eg,ep,ev,re,r,rp)
					local excg=aux.GetValueType(g)=="Group" and g:Clone() or Group.FromCards(g)
					if exc2 then excg:AddCard(e:GetHandler()) end
					return Duel.IsExistingMatchingCard(subject2,tp,loc3,loc4,1,excg,e,tp,eg,ep,ev,re,r,rp)
				end
		sel=	function(g,e,tp,eg,ep,ev,re,r,rp)
					local excg=aux.GetValueType(g)=="Group" and g:Clone() or Group.FromCards(g)
					if exc2 then excg:AddCard(e:GetHandler()) end
					return Duel.SelectMatchingCard(tp,subject2,tp,loc3,loc4,1,1,excg,e,tp,eg,ep,ev,re,r,rp)
				end
	elseif subject2==SUBJECT_THIS_CARD then
		check=	function(g,e)
					local cc=e:GetHandler()
					return not g:IsContains(cc) and cc:IsType(TYPE_XYZ)
				end
		sel=	function(g,e,tp,eg,ep,ev,re,r,rp)
					return Group.FromCards(e:GetHandler())
				end
	else
		check=	function(g,e,tp,eg,ep,ev,re,r,rp)
					local cc=Duel.GetFirstTarget()
					return not g:IsContains(cc) and cc:IsType(TYPE_XYZ)
				end
		sel=	function(g,e,tp,eg,ep,ev,re,r,rp)
					return Group.FromCards(Duel.GetFirstTarget())
				end
	end
	
	if type(subject)=="function" or type(subject)=="nil" then
		subject=action_filter(subject)
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		if (loc1|loc2)&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					local g0=Duel.GetMatchingGroup(subject,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,rp)
					if #g0<min then return end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=g0:SelectSubGroup(tp,check,false,min,max,e,tp,eg,ep,ev,re,rp)
					if #g>0 then
						if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) then
							Duel.HintSelection(g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED))
						end
						local g2=sel(g,e,tp,eg,ep,ev,re,r,rp)
						if #g2>0 then
							aux.CheckSequentiality(conj)
							local ct=fn(g,g2,e,tp,eg,ep,ev,re,r,rp)
							return g1,ct,ct>0,g2
						end
					end
					return g,0,false,g2
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						local g2=sel(c,e,tp,eg,ep,ev,re,r,rp)
						if #g2>0 then
							aux.CheckSequentiality(conj)
							local ct=fn(c,g2,e,tp,eg,ep,ev,re,r,rp)
							return c,ct,ct>0,g2
						end
						return c,0,false,g2
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							local g2=sel(g,e,tp,eg,ep,ev,re,r,rp)
							if #g2>0 then
								aux.CheckSequentiality(conj)
								local ct=fn(g,g2,e,tp,eg,ep,ev,re,r,rp)
								return g,ct,ct>0,g2
							end
							return g,0,false,g2
						end
			return aux.TargetOperation(op)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			truesub=action_filter(truesub)
			if not min then min=1 end
			if not max then max=min end
			if (loc1|loc2)&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local gf=function(sg,...) return GFILTER_TABLE[subject[2]](sg,...) and check(sg,...) end
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g0=Duel.GetMatchingGroup(truesub,tp,loc1,loc2,exc)
						if #g0<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g0:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							if sg:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED) then
								Duel.HintSelection(sg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED))
							end
							local g2=sel(sg,e,tp,eg,ep,ev,re,r,rp)
							if #g2>0 then
								aux.CheckSequentiality(conj)
								local ct=fn(sg,g2,e,tp,eg,ep,ev,re,r,rp)
								return sg,ct,ct>0,g2
							end
						end
						return sg,0,false,g2
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local g2=sel(g,e,tp,eg,ep,ev,re,r,rp)
							if #g2>0 then
								aux.CheckSequentiality(conj)
								local ct=fn(g,g2,e,tp,eg,ep,ev,re,r,rp)
								return g,ct,ct>0,g2
							end
							return g,0,false,g2
						end
			return aux.TargetOperation(op,f,hardchk)
		end
	end
end

function Auxiliary.NotConfirmed(f)
	return	function(c,...)
				return not c:IsPublic() or (not f or f(c,...))
			end
end

--Activate
function Auxiliary.ActivateFilter(f)
	return	function(c,e,tp)
				return (not f or f(c,e,tp)) and c:GetActivateEffect():IsActivatable(tp,true,true)
			end
end
function Auxiliary.ActivateFilterIgnoringPlayer(f)
	return	function(c,e,tp)
				local act=c:GetActivateEffect()
				if not act then return false end
				local save_prop=act:GetProperty()
				if not act:IsHasProperty(EFFECT_FLAG_BOTH_SIDE) then
					act:SetProperty(save_prop+EFFECT_FLAG_BOTH_SIDE)
				end
				local check=act:IsActivatable(tp,true,true)
				act:SetProperty(save_prop)
				return (not f or f(c,e,tp)) and check
			end
end
function Auxiliary.ActivateFieldSpellTarget(f,loc1,loc2,exc)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	if loc2>0 then f=aux.ActivateFilterIgnoringPlayer(f) else f=aux.ActivateFilter(f) end
	
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if exc then exc=e:GetHandler() end
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,1,exc,e,tp) end
				if not Duel.CheckPhaseActivity() then Duel.RegisterFlagEffect(tp,CARD_MAGICAL_MIDBREAKER,RESET_CHAIN,0,1) end
				if loc1>0 and loc2>0 then
					Duel.SetCustomOperationInfo(0,CATEGORY_ACTIVATE,nil,1,PLAYER_ALL,loc1|(loc2&(~loc1)))
				elseif loc1>0 then
					Duel.SetCustomOperationInfo(0,CATEGORY_ACTIVATE,nil,1,tp,loc1)
				elseif loc2>0 then
					Duel.SetCustomOperationInfo(0,CATEGORY_ACTIVATE,nil,1,1-tp,loc1)
				end
			end
end
function Auxiliary.ActivateFieldSpellOperation(f,loc1,loc2,exc)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	if loc2>0 then f=aux.ActivateFilterIgnoringPlayer(f) else f=aux.ActivateFilter(f) end
	if (loc1|loc2)&LOCATION_GRAVE>0 then f=aux.NecroValleyFilter(f) end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				if exc then exc=e:GetHandler() end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
				local g=Duel.SelectMatchingCard(tp,f,tp,loc1,loc2,1,1,exc,e,tp)
				if #g>0 then
					local check=aux.PlayFieldSpell(g:GetFirst(),e,tp,eg,ep,ev,re,r,rp)
					return g,check
				end
				return g,false
			end
end

-----------------------------------------------------------------------
--Attach
function Auxiliary.AttachFilter(f)
	return	function(c,e,...)
				return (not f or f(c,e,...)) and not c:IsType(TYPE_TOKEN) and not c:IsImmuneToEffect(e)
			end
end
function Auxiliary.AttachFilter2(f)
	return	function(c,...)
				return (not f or f(c,e,...)) and c:IsType(TYPE_XYZ)
			end
end
function Auxiliary.AttachTarget(f,loc1,loc2,min,exc,f2,loc3,loc4,exc2,targeted)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=0 end
	if not min then min=1 end
	local locs = (loc1&(~loc2))|loc2
	if not f2 then f2=SUBJECT_THIS_CARD end
	
	local check
	if type(f2)=="function" then
		f2=aux.AttachFilter2(f2)
		if targeted then
			check=	function(g,e,tp,eg,ep,ev,re,r,rp)
						local excg=aux.GetValueType(g)=="Group" and g:Clone() or Group.FromCards(g)
						if exc2 then excg:AddCard(e:GetHandler()) end
						return Duel.IsExistingTarget(f2,tp,loc3,loc4,1,excg,e,tp,eg,ep,ev,re,r,rp)
					end
		else
			check=	function(g,e,tp,eg,ep,ev,re,r,rp)
						local excg=aux.GetValueType(g)=="Group" and g:Clone() or Group.FromCards(g)
						if exc2 then excg:AddCard(e:GetHandler()) end
						return Duel.IsExistingMatchingCard(f2,tp,loc3,loc4,1,excg,e,tp,eg,ep,ev,re,r,rp)
					end
		end
	elseif f2==SUBJECT_THIS_CARD then
		check=	function(g,e)
					local cc=e:GetHandler()
					return not g:IsContains(cc) and cc:IsType(TYPE_XYZ)
				end
	end
	f=aux.AttachFilter(f)
	
	if locs&(LOCATION_HAND+LOCATION_GRAVE+LOCATION_REMOVED+LOCATION_DECK+LOCATION_EXTRA)>0 then
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,rp)
					if chk==0 then return #g>min and g:CheckSubGroup(check,min,max,e,tp,eg,ep,ev,re,r,rp) end
					local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
					if locs&LOCATION_ONFIELD>0 then
						if not Duel.IsExistingMatchingCard(aux.NotConfirmed(f),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,rp) then
							Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,g,min,p,locs)
						else
							Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,min,p,locs)
						end
					else
						Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,nil,min,p,locs)
					end
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp,eg,ep,ev,re,rp)
					if chk==0 then return #g>min and g:CheckSubGroup(check,min,max,e,tp,eg,ep,ev,re,r,rp) end
					local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
					Duel.SetCustomOperationInfo(0,CATEGORY_ATTACH,g,min,p,locs)
				end
	end
end
function Auxiliary.AttachOperation(f,loc1,loc2,min,max,exc,f2,loc3,loc4,exc2)
	local op =	function(g1,g2)
					return Duel.Attach(g1,g2:GetFirst())
				end
	return aux.CardsInteractionOperationTemplate(op,aux.AttachFilter,f,loc1,loc2,min,max,exc,f2,aux.AttachFilter,loc3,loc4,exc2)
end

-----------------------------------------------------------------------
--Banish
function Auxiliary.BanishFilter(f,cost)
	return	function(c,...)
				return (not f or f(c,...)) and (not cost and c:IsAbleToRemove() or cost and c:IsAbleToRemoveAsCost())
			end
end
function Auxiliary.BanishTarget(f,loc1,loc2,min,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=LOCATION_ONFIELD end
	if not min then min=1 end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if exc then exc=e:GetHandler() end
				if chk==0 then return Duel.IsExistingMatchingCard(aux.BanishFilter(f),tp,loc1,loc2,min,exc,e,tp) end
				if loc1>0 and loc2>0 then
					Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,min,PLAYER_ALL,loc1|(loc2&(~loc1)))
				elseif loc1>0 then
					Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,min,tp,loc1)
				elseif loc2>0 then
					Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,min,1-tp,loc1)
				end
			end
end
function Auxiliary.BanishOperation(f,loc1,loc2,min,max,exc)
	local op =	function(g)
					return Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
				end
	return aux.CardMovementOperationTemplate(op,aux.BanishFilter,LOCATION_REMOVED,f,loc1,loc2,min,max,exc)
end


-----------------------------------------------------------------------
--Damage
function Auxiliary.DamageTarget(ct)
	if not ct then ct=1000 end
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return true end
				Duel.SetTargetPlayer(1-tp)
				Duel.SetTargetParam(ct)
				Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,min)
			end
end
function Auxiliary.DamageOperation()
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				return Duel.Damage(p,d,REASON_EFFECT)
			end
end

-----------------------------------------------------------------------
--Destroy
function Auxiliary.DestroyFilter(f)
	return	function(c,e,...)
				return (not f or f(c,e,...)) and c:IsDestructable(e)
			end
end
function Auxiliary.DestroyTarget(f,loc1,loc2,min,exc)
	if not f then f=aux.TRUE end
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=LOCATION_ONFIELD end
	if not min then min=1 end
	local locs = (loc1&(~loc2))|loc2
	
	if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then
		f=aux.DestroyFilter(f)
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
					local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
					if locs&LOCATION_ONFIELD>0 then
						local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
						if not Duel.IsExistingMatchingCard(aux.NotConfirmed(f),tp,loc1,loc2,min,exc,e,tp) then
							Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,min,p,locs)
						else
							Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,min,p,locs)
						end
					else
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,min,p,locs)
					end
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if exc then exc=e:GetHandler() end
					if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc1,loc2,min,exc,e,tp) end
					local p = (loc1>0 and loc2>0) and PLAYER_ALL or (loc1>0) and tp or 1-tp
					local g=Duel.GetMatchingGroup(f,tp,loc1,loc2,exc,e,tp)
					Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,min,p,locs)
				end
	end
end
function Auxiliary.DestroyOperation(subject,loc1,loc2,min,max,exc)
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		local locs = (loc1&(~loc2))|loc2
		if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then subject=aux.DestroyFilter(subject) end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
					local g=Duel.SelectMatchingCard(tp,subject,tp,loc1,loc2,min,max,exc,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						Duel.HintSelection(g)
						local ct=Duel.Destroy(g,REASON_EFFECT)
						return g,ct,ct>0
					end
					return g,0
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function(e,tp,eg,ep,ev,re,r,rp,conj)
						local c=e:GetHandler()
						aux.CheckSequentiality(conj)
						local ct=Duel.Destroy(c,REASON_EFFECT)
						return c,1,ct>0
					end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							local chk=0
							local ct=Duel.Destroy(g,REASON_EFFECT)
							return g,ct,ct>0
						end
			return aux.TargetOperation(op)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&(LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA)>0 then truesub=aux.DestroyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						if exc then exc=e:GetHandler() end
						local g=Duel.GetMatchingGroup(truesub,tp,loc1,loc2,exc)
						if #g<min then return end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,max,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg)
							local ct=Duel.Destroy(sg,REASON_EFFECT)
							return sg,ct,ct>0
						end
						return sg,0
					end
				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local op =	function(g)
							local chk=0
							local ct=Duel.Destroy(g,REASON_EFFECT)
							return g,ct,ct==#g
						end
			return aux.TargetOperation(op,f,hardchk)
		end
	end
end

-----------------------------------------------------------------------
--Discard
function Auxiliary.DiscardFilter(f,cost)
	local r = (not cost) and REASON_EFFECT or REASON_COST
	return	function(c)
				return (not f or f(c)) and c:IsDiscardable(r)
			end
end
function Auxiliary.DiscardTarget(f,min,max,p)
	if not min then min=1 end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				local p = (not p or p==0) and tp or 1-tp
				if chk==0 then return Duel.IsExistingMatchingCard(aux.DiscardFilter(f),p,LOCATION_HAND,0,min,nil) end
				Duel.SetTargetPlayer(p)
				if not max then
					Duel.SetTargetParam(min)
				end
				Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,p,min)
			end
end
function Auxiliary.DiscardOperation(f,min,max,p)
	if not min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
					return Duel.DiscardHand(p,aux.DiscardFilter(f),d,d,REASON_EFFECT+REASON_DISCARD)
				end
	else
		if not max then max=min end
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
					return Duel.DiscardHand(p,aux.DiscardFilter(f),min,max,REASON_EFFECT+REASON_DISCARD)
				end
	end
end

--Draw
function Auxiliary.DrawTarget(min)
	if not min then min=1 end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsPlayerCanDraw(tp,min) end
				Duel.SetTargetPlayer(tp)
				Duel.SetTargetParam(min)
				Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,min)
			end
end
function Auxiliary.DrawOperation()
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				return Duel.Draw(p,d,REASON_EFFECT)
			end
end

-----------------------------------------------------------------------
--Search
function Auxiliary.SearchFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsAbleToHand()
			end
end
function Auxiliary.SearchTarget(f,min,loc,max)
	if not min then min=1 end
	if not loc then loc=LOCATION_DECK end
	local gf
	if type(f)=="table" then
		if #f>1 then
			gf=GFILTER_TABLE[f[2]]
		end
		f=f[1]
	end
	local filter=aux.SearchFilter(f)
	
	if not gf or min==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then return Duel.IsExistingMatchingCard(filter,tp,loc,0,min,nil,e,tp) end
					Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,loc)
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					local g=Duel.GetMatchingGroup(filter,tp,loc,0,nil,e,tp)
					if chk==0 then return g:CheckSubGroup(filter,min,max,e,tp) end
					Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,loc)
				end
	end
end
function Auxiliary.SearchOperation(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_DECK end
	local op =	function(g,_,tp)
					return Duel.Search(g,tp)
				end
	return aux.CardMovementOperationTemplate(op,aux.SearchFilter,LOCATION_HAND+LOCATION_EXTRA,f,loc1,loc2,min,max,exc)
end

--To Deck
function Auxiliary.ToDeckFilter(f,cost,loc)
	return	function(c,...)
				return (not f or f(c,...)) and (not cost and c:IsAbleToDeck() or (cost and ((not loc and c:IsAbleToDeckOrExtraAsCost()) or (loc==LOCATION_DECK and c:IsAbleToDeckAsCost()) or (loc==LOCATION_EXTRA and c:IsAbleToExtraAsCost()))))
			end
end

-----------------------------------------------------------------------
--Negates
function Auxiliary.NegateCondition(monstercon,negateact,rplayer,rf,cond)
	local negatecheck = negateact and Duel.IsChainNegatable or Duel.IsChainDisablable
	return	function(e,tp,eg,ep,ev,re,r,rp)
				return (not monstercon or not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED))
					and (not rplayer or (rplayer==0 and rp==tp) or rp==1-tp)
					and (not rf or (type(rf)=="number" and re:IsActiveType(rf)) or rf(re:GetHandler(),re))
					and (not cond or cond(e,tp,eg,ep,ev,re,r,rp))
					and negatecheck(ev)
			end
end
function Auxiliary.NegateTarget(negateact,negatedop,tg)
	local negcategory = negateact and CATEGORY_NEGATE or CATEGORY_DISABLE
	
	if negatedop==0 then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					if chk==0 then
						return not tg or tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					if tg then
						tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					Duel.SetOperationInfo(0,negcategory,eg,1,0,0)
				end
	elseif negatedop==CATEGORY_DESTROY then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local rc=re:GetHandler()
					local relation=rc:IsRelateToChain(ev)
					if chk==0 then
						return not tg or tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					if tg then
						tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					Duel.SetOperationInfo(0,negcategory,eg,1,0,0)
					if relation then
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,rc,1,rc:GetControler(),rc:GetLocation())
					else
						Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,rc:GetPreviousControler(),rc:GetPreviousLocation())
					end
				end
	else
		local chktab = {
			[CATEGORY_REMOVE]	={Card.IsAbleToRemove,Duel.IsPlayerCanRemove};
			[CATEGORY_TOHAND]	={function(c) return c:IsAbleToHand() end,Duel.IsPlayerCanSendtoHand};
			[CATEGORY_TOGRAVE]	={function(c) return c:IsAbleToGrave() end,Duel.IsPlayerCanSendtoGrave};
			[CATEGORY_TODECK]	={function(c) return c:IsAbleToDeck() end,Duel.IsPlayerCanSendtoDeck};
		}
		local rcchk,pchk=chktab[negatedop][1],chktab[negatedop][2]
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local rc=re:GetHandler()
					local relation=rc:IsRelateToChain(ev)
					if chk==0 then
						return (rcchk(rc,tp) or (not relation and pchk(tp)))
							and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,chk))
					end
					if tg then
						tg(e,tp,eg,ep,ev,re,r,rp,chk)
					end
					Duel.SetOperationInfo(0,negcategory,eg,1,0,0)
					if relation then
						Duel.SetOperationInfo(0,negatedop,rc,1,rc:GetControler(),rc:GetLocation())
					else
						Duel.SetOperationInfo(0,negatedop,nil,0,rc:GetPreviousControler(),rc:GetPreviousLocation())
					end
				end
	end
end
function Auxiliary.NegateOperation(negateact,negatedop)
	local negtype = negateact and Duel.NegateActivation or Duel.NegateEffect
	if negatedop==0 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					return negtype(ev)
				end
	else
		local actiontab = {
			[CATEGORY_DESTROY]	=Duel.Destroy;
			[CATEGORY_REMOVE]	=function(c,r) return Duel.Remove(c,POS_FACEUP,r) end;
			[CATEGORY_TOHAND]	=function(c,r) return Duel.SendtoHand(c,nil,r) end;
			[CATEGORY_TOGRAVE]	=Duel.SendtoGrave;
			[CATEGORY_TODECK]	=function(c,r) return Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,r) end;
		}
		local chktab = {
			[CATEGORY_DESTROY]	=function(g) return #g>0 end;
			[CATEGORY_REMOVE]	=function(g) return aux.PLChk(g,nil,LOCATION_REMOVED) end;
			[CATEGORY_TOHAND]	=function(g) return aux.PLChk(g,nil,LOCATION_HAND+LOCATION_EXTRA) end;
			[CATEGORY_TOGRAVE]	=function(g) return aux.PLChk(g,nil,LOCATION_GRAVE) end;
			[CATEGORY_TODECK]	=function(g) return aux.PLChk(g,nil,LOCATION_DECK+LOCATION_EXTRA) end;
		}
		local action=actiontab[negatedop]
		local check=chktab[negatedop]
		return	function (e,tp,eg,ep,ev,re,r,rp)
					if negtype(ev) and re:GetHandler():IsRelateToChain(ev) then
						local ct=action(eg,REASON_EFFECT)
						return eg,ct,aux.PLChk(eg,nil,loc)
					end
					return false
				end
	end
end

function Auxiliary.NegateAttackOperation()
	local res=Duel.NegateAttack()
	return res
end

-----------------------------------------------------------------------
--Normal Summons
function Auxiliary.NSFilter(f)
	return	function(c,...)
				return (not f or f(c,...)) and c:IsSummonable(true,nil)
			end
end
function Auxiliary.NSTarget(f,loc1)
	if not loc1 then loc1=LOCATION_HAND+LOCATION_MZONE else loc1=loc1&(LOCATION_HAND+LOCATION_MZONE) end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(aux.NSFilter(f),tp,loc1,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
				Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,loc1)
			end
end
function Auxiliary.NSOperation(subject,loc1)
	if type(subject)=="function" or type(subject)=="nil" then
		if not loc1 then loc1=LOCATION_HAND+LOCATION_MZONE else loc1=loc1&(LOCATION_HAND+LOCATION_MZONE) end
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.NSFilter(subject),tp,loc1,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						Duel.Summon(tp,g:GetFirst(),true,nil)
						return g,1,true
					end
					return g,1
				end
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				if not c:IsRelateToChain() then return end
				aux.CheckSequentiality(conj)
				Duel.Summon(tp,c,true,nil)
				return c,1,true
			end
					
		elseif subject==SUBJECT_IT then
			local op =	function(g)
							Duel.Summon(tp,g:GetFirst(),true,nil)
							return g,1,true
						end
			return aux.TargetOperation(op)
		end
	
	else
		local truesub=subject[1]
		if truesub==SUBJECT_THAT_TARGET then
			local f=subject[2]
			local op =	function(g)
							Duel.Summon(tp,g:GetFirst(),true,nil)
							return g,1,true
						end
			return aux.TargetOperation(op,f)
		end
	end
end

-----------------------------------------------------------------------
--Special Summons
SPSUM_MOD_NEGATE   		= 0x1
SPSUM_MOD_REDIRECT 		= 0x2
SPSUM_MOD_CHANGE_ATKDEF	=	0x4

function Auxiliary.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone)
	return	function(c,e,tp,...)
				return (not f or f(c,e,tp,...)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,recp,zone)
			end
end
function Auxiliary.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2)
	return	function(c,e,tp,...)
				return (not f or f(c,e,tp,...))
					and (c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2))
			end
end

function Auxiliary.SSTarget(f,loc1,loc2,min,exc,sumtype,sump,ign1,ign2,pos,recp,zone)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	local locs = (loc1&(~loc2))|loc2
	if not min then min=1 end
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone then zone=0xff end
	
	if type(f)=="function" or type(f)=="nil" then
		if min==1 then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						if exc then exc=e:GetHandler() end
						if chk==0 then return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=min and Duel.IsExistingMatchingCard(aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp) end
						if loc1>0 and loc2>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
						elseif loc1>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
						elseif loc2>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
						end
					end
		else
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						if exc then exc=e:GetHandler() end
						if chk==0 then
							return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=min and Duel.IsExistingMatchingCard(aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp)
						end
						if loc1>0 and loc2>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
						elseif loc1>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
						elseif loc2>0 then
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
						end
					end
		end
	elseif type(f)=="number" then
		if f==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,chk)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						local c=e:GetHandler()
						if exc then exc=c end
						if chk==0 then return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=min and c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,recp,zone) end
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
					end
		end
	end
end
function Auxiliary.SSOperationTemplate(f,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone)
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	end
end
function Auxiliary.SSOperation(subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone,complete_proc)
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone then zone=0xff end
	
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		local locs = (loc1&(~loc2))|loc2
		if locs&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return aux.SSOperationTemplate(subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone)
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				local sump = sump and sump==1 and 1-tp or tp
				local recp = recp and recp==1 and 1-tp or tp
				local zone = type(zone)=="number" and zone or zone(e,tp)
				if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<=0 or not c:IsRelateToChain() then return end
				aux.CheckSequentiality(conj)
				local ct=Duel.SpecialSummon(c,sumtype,sump,recp,ign1,ign2,pos,zone)
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return c,ct,ct>0
			end
					
		elseif subject==SUBJECT_IT then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,nil,nil,chk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						if exc then exc=e:GetHandler() end
						local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
						local g=Duel.GetMatchingGroup(aux.SSFilter(truesub,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,exc)
						if #g<min or ft<min or (min>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
						
						if ft>max then ft=max end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,ft,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg)
							local ct=Duel.SpecialSummon(sg,sumtype,sump,recp,ign1,ign2,pos,zone)
							return sg,ct,ct>0
						end
						return sg,0
					end

				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=Duel.SpecialSummon(g,sumtype,sump,recp,ign1,ign2,pos,zone)
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,hardchk,nil,chk)
		end
	end
end

function Auxiliary.SSOperationMod(mod,subject,loc1,loc2,min,max,exc,modvals,sumtype,sump,ign1,ign2,pos,recp,zone,complete_proc)
	if type(modvals)~="table" then
		modvals={modvals}
	end
	if not mod then mod=SPSUM_MOD_NEGATE end
	local spsum
	if mod==SPSUM_MOD_NEGATE then
		spsum=Duel.SpecialSummonNegate
	elseif mod==SPSUM_MOD_REDIRECT then
		spsum=Duel.SpecialSummonRedirect
	elseif mod==SPSUM_MOD_CHANGE_ATKDEF then
		spsum=Duel.SpecialSummonATKDEF
	end
	
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone then zone=0xff end
	
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		local locs = (loc1&(~loc2))|loc2
		if locs&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return aux.SSOperationModTemplate(spsum,subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone,table.unpack(modvals))
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				local sump = sump and sump==1 and 1-tp or tp
				local recp = recp and recp==1 and 1-tp or tp
				local zone = type(zone)=="number" and zone or zone(e,tp)
				if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<=0 or not c:IsRelateToChain() then return end

				aux.CheckSequentiality(conj)
				local ct=spsum(e,c,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return c,ct,ct>0
			end
					
		elseif subject==SUBJECT_IT then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,nil,nil,chk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						local sump = sump and sump==1 and 1-tp or tp
						local recp = recp and recp==1 and 1-tp or tp
						local zone = type(zone)=="number" and zone or zone(e,tp)
						if exc then exc=e:GetHandler() end
						local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
						local g=Duel.GetMatchingGroup(aux.SSFilter(truesub,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,exc)
						if #g<min or ft<min or (min>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
						if ft>max then ft=max end

						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,ft,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg)
							local ct=spsum(e,sg,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
							return sg,ct,ct>0
						end
						return sg,0
					end

				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							return Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local recp = recp and recp==1 and 1-tp or tp
							local zone = type(zone)=="number" and zone or zone(e,tp)
							local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,hardchk,nil,chk)
		end
	end
end
function Auxiliary.SSOperationModTemplate(spsum,f,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,recp,zone,...)
	local modvals={...}
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					if Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)<min then return end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					local zone = type(zone)=="number" and zone or zone(e,tp)
					local ft=Duel.GetLocationCount(recp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone)
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSFilter(f,sumtype,sump,ign1,ign2,pos,recp,zone),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,recp,ign1,ign2,pos,zone,table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	end
end

function Auxiliary.SSToEitherFieldTarget(f,loc1,loc2,min,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2)
	if not loc1 then loc1=LOCATION_DECK end
	if not loc2 then loc2=0 end
	local locs = (loc1&(~loc2))|loc2
	if not min then min=1 end
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone1 then zone1=0xff end
	if not zone2 then zone2=0xff end
	
	if min==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					if exc then exc=e:GetHandler() end
					if chk==0 then
						local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
						local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
						return (ft1>=min or ft2>=min)
						and Duel.IsExistingMatchingCard(aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp) end
					if loc1>0 and loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
					elseif loc1>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
					elseif loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
					end
				end
	else
		return	function (e,tp,eg,ep,ev,re,r,rp,chk)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					if exc then exc=e:GetHandler() end
					if chk==0 then
						local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
						local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
						return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
						and ft1+ft2>=min
						and Duel.IsExistingMatchingCard(aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,exc,e,tp,eg,ep,ev,re,r,rp)
					end
					if loc1>0 and loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,PLAYER_ALL,locs)
					elseif loc1>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,tp,loc1)
					elseif loc2>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,1-tp,loc1)
					end
				end
	end
end
function Auxiliary.SSToEitherFieldOperation(subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2,complete_proc)
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone1 then zone1=0xff end
	if not zone2 then zone2=0xff end
	
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		local locs = (loc1&(~loc2))|loc2
		if locs&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return aux.SSToEitherFieldOperationTemplate(subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2)
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				local sump = sump and sump==1 and 1-tp or tp
				local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
				local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
				local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
				if ft1+ft2<=0 or not c:IsRelateToChain() then return end
				aux.CheckSequentiality(conj)
				local recp,finalzone=tp,zone1
				if c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
					recp,finalzone=1-tp,zone2
				end
				local ct=Duel.SpecialSummon(c,sumtype,sump,recp,ign1,ign2,pos,finalzone)
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return c,ct,ct>0
			end
					
		elseif subject==SUBJECT_IT then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=0
							for tc in aux.Next(g) do
								local recp,finalzone=tp,zone1
								if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
									recp,finalzone=1-tp,zone2
								end
								if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
									ct=ct+1
								end
							end
							Duel.SpecialSummonComplete()
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,nil,nil,chk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						local sump = sump and sump==1 and 1-tp or tp
						local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
						local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
						local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
						local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
						if exc then exc=e:GetHandler() end
						local ft=ft1+ft2
						local g=Duel.GetMatchingGroup(aux.SSToEitherFieldFilter(truesub,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,exc)
						if #g<min or ft<min or (min>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
						
						if ft>max then ft=max end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,ft,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							local ct=0
							for tc in aux.Next(sg) do
								local recp,finalzone=tp,zone1
								if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
									recp,finalzone=1-tp,zone2
								end
								if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
									ct=ct+1
								end
							end
							Duel.SpecialSummonComplete()
							return sg,ct,ct>0
						end
						return sg,0
					end

				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=0
							for tc in aux.Next(g) do
								local recp,finalzone=tp,zone1
								if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
									recp,finalzone=1-tp,zone2
								end
								if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
									ct=ct+1
								end
							end
							Duel.SpecialSummonComplete()
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,hardchk,nil,chk)
		end
	end
end
function Auxiliary.SSToEitherFieldOperationTemplate(f,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2)
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					if ft1+ft2<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local tc=g:GetFirst()
						local recp,finalzone=tp,zone1
						if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
							recp,finalzone=1-tp,zone2
						end
						local ct=Duel.SpecialSummon(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone)
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					local ft=ft1+ft2
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=0
						for tc in aux.Next(g) do
							local recp,finalzone=tp,zone1
							if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
								recp,finalzone=1-tp,zone2
							end
							if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
								ct=ct+1
							end
						end
						Duel.SpecialSummonComplete()
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					if ft1+ft2<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=0
						for tc in aux.Next(g) do
							local recp,finalzone=tp,zone1
							if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
								recp,finalzone=1-tp,zone2
							end
							if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
								ct=ct+1
							end
						end
						Duel.SpecialSummonComplete()
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp,conj)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					local ft=ft1+ft2
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					local sump = sump and sump==1 and 1-tp or tp
					local recp = recp and recp==1 and 1-tp or tp
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						aux.CheckSequentiality(conj)
						local ct=0
						for tc in aux.Next(g) do
							local recp,finalzone=tp,zone1
							if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
								recp,finalzone=1-tp,zone2
							end
							if Duel.SpecialSummonStep(tc,sumtype,sump,recp,ign1,ign2,pos,finalzone) then
								ct=ct+1
							end
						end
						Duel.SpecialSummonComplete()
						return Duel.GetOperatedGroup(),ct,ct>0
					end
					return g,0
				end
	end
end

function Auxiliary.SSToEitherFieldOperationMod(mod,subject,loc1,loc2,min,max,exc,modvals,sumtype,sump,ign1,ign2,pos,zone1,zone2,complete_proc)
	if type(modvals)~="table" then
		modvals={modvals}
	end
	if not mod then mod=SPSUM_MOD_NEGATE end
	local spsum
	if mod==SPSUM_MOD_NEGATE then
		spsum=Duel.SpecialSummonNegate
	elseif mod==SPSUM_MOD_REDIRECT then
		spsum=Duel.SpecialSummonRedirect
	end
	
	if not sumtype then sumtype=0 end
	if not ign1 then ign1=false end
	if not ign2 then ign2=false end
	if not pos then pos=POS_FACEUP end
	if not zone1 then zone1=0xff end
	if not zone2 then zone2=0xff end
	
	if type(subject)=="function" or type(subject)=="nil" then
		if not min then min=1 end
		if not max then max=min end
		if not loc1 then loc1=LOCATION_MZONE end
		if not loc2 then loc2=0 end
		local locs = (loc1&(~loc2))|loc2
		if locs&LOCATION_GRAVE>0 then subject=aux.NecroValleyFilter(subject) end
		return aux.SSOperationModTemplate(spsum,subject,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2,table.unpack(modvals))
				
	elseif type(subject)=="number" then
		if subject==SUBJECT_THIS_CARD then
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
				local c=e:GetHandler()
				local sump = sump and sump==1 and 1-tp or tp
				local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
				local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
				local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
				local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
				if ft1+ft2<=0 or not c:IsRelateToChain() then return end
				aux.CheckSequentiality(conj)
				local recp,finalzone=tp,zone1
				if c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone2) and (not c:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,zone1) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
					recp,finalzone=1-tp,zone2
				end
				local ct=spsum(e,c,sumtype,sump,recp,ign1,ign2,pos,finalzone,table.unpack(modvals))
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return c,ct,ct>0
			end
					
		elseif subject==SUBJECT_IT then
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,nil,nil,nil,chk)
		end
	
	else
		local truesub=subject[1]
		if type(truesub)=="function" or type(truesub)=="nil" then
			if not min then min=1 end
			if not max then max=min end
			if not loc1 then loc1=LOCATION_MZONE end
			if not loc2 then loc2=0 end
			local locs = (loc1&(~loc2))|loc2
			if locs&LOCATION_GRAVE>0 then truesub=aux.NecroValleyFilter(truesub) end
			local gf=GFILTER_TABLE[subject[2]]
			return	function (e,tp,eg,ep,ev,re,r,rp,conj)
						local sump = sump and sump==1 and 1-tp or tp
						local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
						local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
						local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
						local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
						if exc then exc=e:GetHandler() end
						local ft=ft1+ft2
						local g=Duel.GetMatchingGroup(aux.SSToEitherFieldFilter(truesub,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,exc)
						if #g<min or ft<min or (min>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then return end
						if ft>max then ft=max end

						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
						local sg=g:SelectSubGroup(tp,gf,false,min,ft,e,tp,eg,ep,ev,re,r,rp)
						if #sg>0 then
							aux.CheckSequentiality(conj)
							Duel.HintSelection(sg)
							local ct=spsum(e,sg,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
							return sg,ct,ct>0
						end
						return sg,0
					end

				
		elseif truesub==SUBJECT_THAT_TARGET or truesub==SUBJECT_ALL_THOSE_TARGETS then
			local f=subject[2]
			local hardchk=(truesub==SUBJECT_ALL_THOSE_TARGETS)
			local chk =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
							local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
							return ft1+ft2>=#g and (#g<2 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
						end
			local op =	function(g,e,tp)
							local sump = sump and sump==1 and 1-tp or tp
							local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
							local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
							local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
							return g,ct,ct>0
						end
			return aux.TargetOperation(op,f,hardchk,nil,chk)
		end
	end
end
function Auxiliary.SSToEitherFieldOperationModTemplate(mod,f,loc1,loc2,min,max,exc,sumtype,sump,ign1,ign2,pos,zone1,zone2,...)
	local modvals={...}
	if min==1 and max==1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					if ft1+ft2<min then return end
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min==1 and max>1 then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					local ft=ft1+ft2
					if ft<min then return end
					if ft>max then ft=max end
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max==min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or ft1+ft2<min then return end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	elseif min>1 and max>min then
		return	function (e,tp,eg,ep,ev,re,r,rp)
					local sump = sump and sump==1 and 1-tp or tp
					local zone1 = type(zone1)=="number" and zone1 or zone1(e,tp)
					local zone2 = type(zone2)=="number" and zone2 or zone2(e,tp)
					local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone1)
					local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,sump,LOCATION_REASON_TOFIELD,zone2)
					local ft=ft1+ft2
					if ft<min or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
					if ft>max then ft=max end
					
					if exc then exc=e:GetHandler() end
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local g=Duel.SelectMatchingCard(tp,aux.SSToEitherFieldFilter(f,sumtype,sump,ign1,ign2,pos,zone1,zone2),tp,loc1,loc2,min,ft,exc,e,tp)
					if #g>0 then
						local ct=spsum(e,g,sumtype,sump,tp,ign1,ign2,pos,{zone1,zone2},table.unpack(modvals))
						return g,ct
					end
					return g,0
				end
	end
end

function Auxiliary.ZoneThisCardPointsTo(p)
	return	function(e,tp)
				local p = (p and p==0) and tp or (p and p==1) and 1-tp or nil
				return e:GetHandler():GetLinkedZone(p)
			end
end
function Auxiliary.ZoneThisCardDoesNotPointTo(p)
	return	function(e,tp)
				local p = (p and p==0) and tp or (p and p==1) and 1-tp or nil
				local field = (p and (p==0 or p==1)) and 0x1f or 0xff
				return (~(e:GetHandler():GetLinkedZone(p)))&field
			end
end
-----------------------------------------------
--SELF
--[[
Places counters on itself equal to the number of cards involved in an event, multiplied by (ct)
* (ctype) = Counter type
* (ct) = Default is 1. The number multiplied with the number of cards involved to get the total amount of counters that will be placed
* (f) = Filter for the cards involved in the event. Only the cards that satisfy the filter will be counted for the Counters' placement.
]]
function Auxiliary.EventCounterSelfOperation(ctype,ct,f)
	if not ct then ct=1 end
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				local tot=eg:FilterCount(f,nil,e,tp,eg,ep,ev,re,r,rp)*ct
				if tot>0 and c:IsCanAddCounter(ctype,tot,true) then
					c:AddCounter(ctype,tot,true)
				end
			end
end

function Auxiliary.PositionSelfTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanChangePosition() end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function Auxiliary.PositionSelfOperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsCanChangePosition() then
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end


function Auxiliary.SSSelfTarget(loc_clause)
	if loc_clause~=nil and aux.GetValueType(loc_clause)~="table" then loc_clause={LOCATION_GRAVE,LOCATION_HAND} end
	
	return	function (e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then
					return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
						and (not loc_clause or ((c:IsLocation(loc_clause[1]) and not eg:IsContains(c)) or (c:IsLocation(loc_clause[2]))))
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
			end
end
function Auxiliary.SSSelfOperation(complete_proc)
	return	function (e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not c:IsRelateToChain() then return end
				local ct=Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
				if ct~=0 and complete_proc then
					c:CompleteProcedure()
				end
				return ct
			end
end

-----------------------------------------------
--SPECIAL SUMMON
function Duel.SpecialSummonATK(e,g,styp,sump,tp,ign1,ign2,pos,zone,atk,reset,rc)
	if not zone then zone=0xff end
	if not reset then reset=0 end
	if not rc then rc=e:GetHandler() end
	if aux.GetValueType(g)=="Card" then
		if g==e:GetHandler() and rc==e:GetHandler() then reset=reset|RESET_DISABLE end
		g=Group.FromCards(g)
	end
	local ct=0
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[tp+1]
			if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone[2-tp]) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				tp=1-tp
				finalzone=zone[tp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos,finalzone) then
			ct=ct+1
			local e1=Effect.CreateEffect(rc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			dg:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end
function Duel.SpecialSummonNegate(e,g,styp,sump,tp,ign1,ign2,pos,zone,reset,rc)
	if not zone then zone=0xff end
	if not reset then reset=0 end
	if not rc then rc=e:GetHandler() end
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[tp+1]
			if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone[2-tp]) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				tp=1-tp
				finalzone=zone[tp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos,finalzone) then
			ct=ct+1
			local e1=Effect.CreateEffect(rc)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			dg:RegisterEffect(e1,true)
			local e2=Effect.CreateEffect(rc)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+reset)
			dg:RegisterEffect(e2,true)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end
function Duel.SpecialSummonRedirect(e,g,styp,sump,tp,ign1,ign2,pos,zone,loc)
	if not zone then zone=0xff end
	if not loc then loc=LOCATION_REMOVED end
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[tp+1]
			if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone[2-tp]) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				tp=1-tp
				finalzone=zone[tp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos,finalzone) then
			ct=ct+1
			local e=Effect.CreateEffect(e:GetHandler())
			e:SetType(EFFECT_TYPE_SINGLE)
			e:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e:SetValue(loc)
			e:SetReset(RESET_EVENT+RESETS_REDIRECT_FIELD)
			dg:RegisterEffect(e,true)
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end
function Duel.SpecialSummonATKDEF(e,g,styp,sump,tp,ign1,ign2,pos,zone,atk,def)
	if not zone then zone=0xff end
	if aux.GetValueType(g)=="Card" then g=Group.FromCards(g) end
	local ct=0
	for dg in aux.Next(g) do
		local finalzone=zone
		if type(zone)=="table" then
			finalzone=zone[tp+1]
			if tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,1-tp,zone[2-tp]) and (not tc:IsCanBeSpecialSummoned(e,sumtype,sump,ign1,ign2,pos,tp,finalzone) or Duel.SelectYesNo(sump,aux.Stringid(61665245,2))) then
				tp=1-tp
				finalzone=zone[tp+1]
			end
		end
		if Duel.SpecialSummonStep(dg,styp,sump,tp,ign1,ign2,pos,finalzone) then
			ct=ct+1
			local e=Effect.CreateEffect(e:GetHandler())
			e:SetType(EFFECT_TYPE_SINGLE)
			e:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e:SetReset(RESET_EVENT+RESETS_STANDARD)
			if atk then
				e:SetCode(EFFECT_SET_ATTACK)
				e:SetValue(atk)
				dg:RegisterEffect(e,true)
			end
			if def then
				local e=e:Clone()
				e:SetCode(EFFECT_SET_DEFENSE)
				e:SetValue(def)
				dg:RegisterEffect(e,true)
			end
		end
	end
	Duel.SpecialSummonComplete()
	return ct
end