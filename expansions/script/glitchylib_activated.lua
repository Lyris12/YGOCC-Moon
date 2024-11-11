Glitchy=Glitchy or {}
xgl=Glitchy

--Target check constants
TGCHECK_IT 					= 0
TGCHECK_THAT_TARGET			= 1
TGCHECK_ALL_THOSE_TARGETS	= 2

--Create chkc line
function Glitchy.CreateChkc(chkc,e,tp,loc1,loc2,exc,f,...)
	if exc and chkc==e:GetHandler() then return false end
	if f and not f(chkc,...) then return false end
	if loc1==loc2 then
		return chkc:IsLocation(loc1) 
	else
		return (chkc:IsLocation(loc1) and chkc:IsControler(tp)) or (chkc:IsLocation(loc2) and chkc:IsControler(1-tp))
	end
end

--Create check for targets at the time of resolution
function Glitchy.CheckTargetsAtResolution(tgcheck,loc1,loc2,tp,g,f,...)
	local ctchk
	if tgcheck==TGCHECK_ALL_THOSE_TARGETS then
		local ogtg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local fg=g:Filter(xgl.CreateChkc,nil,nil,tp,loc1,loc2,nil,f,...)
		return #ogtg==#fg, g
	else
		if tgcheck==TGCHECK_THAT_TARGET then
			g=g:Sub(aux.NOT(xgl.CreateChkc),nil,nil,tp,loc1,loc2,nil,f,...)
		end
		return #g>0, g
	end
end
--

--Draw effect template
function Glitchy.DrawTarget(p,val)
	val=val and val or 1
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local p=p==0 and tp or 1-tp
				if chk==0 then return Duel.IsPlayerCanDraw(p,val) end
				Duel.SetTargetPlayer(p)
				Duel.SetTargetParam(val)
				aux.DrawInfo(p,val)
			end
end
function Glitchy.DrawOperation()
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
				Duel.Draw(p,d,REASON_EFFECT)
			end
end

--Search effect templates: Add N card(s) from LOCATION to your hand
function Glitchy.SearchTarget(f,loc,min,exc)
	f=aux.SearchFilter(f)
	loc=loc or LOCATION_DECK
	min=min or 1
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then
					local exc=exc and e:GetHandler() or nil
					return Duel.IsExistingMatchingCard(f,tp,loc,0,min,exc,e,tp)
				end
				Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,min,tp,loc)
			end
end
function Glitchy.SearchOperation(f,loc,min,max,exc)
	loc=loc or LOCATION_DECK
	f=aux.SearchFilter(f)
	if loc&LOCATION_GRAVE>0 then
		f=aux.NecroValleyFilter(f)
	end
	min=min or 1
	max=max or min
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local exc=exc and e:GetHandler() or nil
				local g=Duel.Select(HINTMSG_ATOHAND,false,tp,f,tp,loc,0,min,max,exc,e,tp)
				if #g>0 then
					Duel.Search(g)
				end
			end
end

--Special Summon effect template
function Glitchy.SpecialSummonFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
	return	function(c,e,tp)
				return (not f or f(c,e,tp)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ignore_sumcon,ignore_revlim,pos,recp)
			end
end
function Glitchy.SpecialSummonFromExtraDeckFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
	return	function(c,e,tp)
				return (not f or f(c,e,tp)) and Duel.GetLocationCountFromEx(sump,recp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,sumtype,sump,ignore_sumcon,ignore_revlim,pos,recp)
			end
end
function Glitchy.SpecialSummonFilterX(ftcheck,f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
	return	function(c,e,tp)
				if not ((not f or f(c,e,tp)) and c:IsCanBeSpecialSummoned(e,sumtype,sump,ignore_sumcon,ignore_revlim,pos,recp)) then return false end
				local edchk=c:IsInExtra()
				if edchk then
					return Duel.GetLocationCountFromEx(sump,recp,nil,c)>0
				else
					return ftcheck
				end
			end
end
function Glitchy.SpecialSummonTarget(tgchk,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim,pos)
	loc1=loc1 or 0
	loc2=loc2 or 0
	min=min or 1
	max=max or min
	sumtype=sumtype or 0
	pos=pos or POS_FACEUP
	if ignore_sumcon==nil then ignore_sumcon=false end
	if ignore_revlim==nil then ignore_revlim=false end
	local locs=loc1|loc2
	local EDchk=locs&LOCATION_EXTRA>0
	local minchk=min==1
	if not tgchk then
		if not EDchk then
			return	function(e,tp,eg,ep,ev,re,r,rp,chk)
						local exc=exc and e:GetHandler() or nil
						local sump=IsOpponentSummons and 1-tp or tp
						local recp=IsOpponentReceives and 1-tp or tp
						if chk==0 then
							if min>1 and Duel.IsPlayerAffectedByEffect(sump,CARD_BLUEEYES_SPIRIT) then return false end
							local ft=Duel.GetMZoneCount(sump,nil,recp)
							return ft>=min and Duel.IsExists(false,xgl.SpecialSummonFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos),tp,loc1,loc2,min,exc,e,tp)
						end
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,players,locs)
					end
		elseif minchk then
			if locs==LOCATION_EXTRA then
				return	function(e,tp,eg,ep,ev,re,r,rp,chk)
							local exc=exc and e:GetHandler() or nil
							local sump=IsOpponentSummons and 1-tp or tp
							local recp=IsOpponentReceives and 1-tp or tp
							if chk==0 then
								return Duel.IsExists(false,xgl.SpecialSummonFromExtraDeckFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos),tp,loc1,loc2,min,exc,e,tp)
							end
							local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,players,locs)
						end
			else
				return	function(e,tp,eg,ep,ev,re,r,rp,chk)
							local exc=exc and e:GetHandler() or nil
							local sump=IsOpponentSummons and 1-tp or tp
							local recp=IsOpponentReceives and 1-tp or tp
							if chk==0 then
								local ft=Duel.GetMZoneCount(sump,nil,recp)
								return Duel.IsExists(false,xgl.SpecialSummonFilterX(ft>0,f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos),tp,loc1,loc2,min,exc,e,tp)
							end
							local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
							Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,players,locs)
						end
			end
		end
	
	elseif tgchk and not edchk then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					local exc=exc and e:GetHandler() or nil
					local sump=IsOpponentSummons and 1-tp or tp
					local recp=IsOpponentReceives and 1-tp or tp
					local spf=xgl.SpecialSummonFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
					if chkc then
						return xgl.CreateChkc(chkc,e,tp,loc1,loc2,exc,spf,e,tp)
					end
					local ft=Duel.GetMZoneCount(sump,nil,recp)
					if chk==0 then
						if min>1 and Duel.IsPlayerAffectedByEffect(sump,CARD_BLUEEYES_SPIRIT) then return false end
						return ft>=min and Duel.IsExists(true,spf,tp,loc1,loc2,min,exc,e,tp)
					end
					local maxc=Duel.IsPlayerAffectedByEffect(sump,CARD_BLUEEYES_SPIRIT) and 1 or math.min(max,ft)
					local g=Duel.Select(HINTMSG_SPSUMMON,true,tp,spf,tp,loc1,loc2,min,maxc,exc,e,tp)
					if #g>0 then
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
					else
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,min,players,locs)
					end
				end
	end
end

function Glitchy.SpecialSummonOperation(spmod,tgcheck,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim,pos)
	local spfunc,spparams=nil,{}
	if type(f)=="number" then
		tgcheck,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim,pos = spmod,tgcheck,f,loc1,loc2,min,max,exc,sumtype,IsOpponentSummons,IsOpponentReceives,ignore_sumcon,ignore_revlim
	else
		if type(spmod)=="table" then
			spfunc=spmod[1]
			if #spmod>=2 then
				for i=2,#spmod do
					table.insert(spparams,spmod[i])
				end
			end
		else
			spfunc=spmod
		end
	end
	if not loc1 and not loc2 then Debug.Message("Undefined locations when calling Glitchy.SpecialSummonOperation") return end
	loc1=loc1 or 0
	loc2=loc2 or 0
	sumtype=sumtype or 0
	pos=pos or POS_FACEUP
	if ignore_sumcon==nil then ignore_sumcon=false end
	if ignore_revlim==nil then ignore_revlim=false end
	if not tgcheck then
		min=min or 1
		max=max or min
		local locs=loc1|loc2
		local EDchk=locs&LOCATION_EXTRA>0
		local minchk=min==1
		
		if locs&LOCATION_GRAVE>0 then
			f=aux.Necro(f)
		end
		
		if not EDchk then
			return	function(e,tp,eg,ep,ev,re,r,rp)
						local exc=exc and e:GetHandler() or nil
						local sump=IsOpponentSummons and 1-tp or tp
						local recp=IsOpponentReceives and 1-tp or tp
						local ft=Duel.GetMZoneCount(sump,nil,recp)
						if ft<=0 then return end
						local blue_eyes_spirit_check=Duel.IsPlayerAffectedByEffect(sump,CARD_BLUEEYES_SPIRIT)
						if min>1 and blue_eyes_spirit_check then return false end
						local maxc=blue_eyes_spirit_check and 1 or math.min(max,ft)
						local spf=xgl.SpecialSummonFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
						local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,spf,tp,loc1,loc2,min,maxc,exc,e,tp)
						if #g>=min then
							if not spmod then
								Duel.SpecialSummon(g,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
							else
								spfunc(e,g,styp,sump,tp,ign1,ign2,pos,nil,table.unpack(spparams))
							end
						end
					end
					
		elseif minchk then
			if locs==LOCATION_EXTRA then
				return	function(e,tp,eg,ep,ev,re,r,rp,chk)
							local exc=exc and e:GetHandler() or nil
							local sump=IsOpponentSummons and 1-tp or tp
							local recp=IsOpponentReceives and 1-tp or tp
							local spf=xgl.SpecialSummonFromExtraDeckFilter(f,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
							local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,spf,tp,loc1,loc2,min,maxc,exc,e,tp)
							if #g>=min then
								if not spmod then
									Duel.SpecialSummon(g,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
								else
									spfunc(e,g,styp,sump,tp,ign1,ign2,pos,nil,table.unpack(spparams))
								end
							end
						end
			else
				return	function(e,tp,eg,ep,ev,re,r,rp,chk)
							local exc=exc and e:GetHandler() or nil
							local sump=IsOpponentSummons and 1-tp or tp
							local recp=IsOpponentReceives and 1-tp or tp
							local ft=Duel.GetMZoneCount(sump,nil,recp)
							local spf=xgl.SpecialSummonFilterX(ft>0,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
							local g=Duel.Select(HINTMSG_SPSUMMON,false,tp,spf,tp,loc1,loc2,min,maxc,exc,e,tp)
							if #g>=min then
								if not spmod then
									Duel.SpecialSummon(g,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
								else
									spfunc(e,g,styp,sump,tp,ign1,ign2,pos,nil,table.unpack(spparams))
								end
							end
						end
			end
		end
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local sump=IsOpponentSummons and 1-tp or tp
					local recp=IsOpponentReceives and 1-tp or tp
					local og=Duel.GetTargetCards()
					local res,g=xgl.CheckTargetsAtResolution(tgcheck,loc1,loc2,tp,og,f,e,tp)
					if res then
						if not spmod then
							Duel.SpecialSummon(g,sumtype,sump,recp,ignore_sumcon,ignore_revlim,pos)
						else
							spfunc(e,g,styp,sump,tp,ign1,ign2,pos,nil,table.unpack(spparams))
						end
					end
				end
	end
end

--Sendto template: Move a card(s) from a location to another
Glitchy.SendtoFilters={
	[LOCATION_DECK]=Auxiliary.ToDeckFilter;
	[LOCATION_GRAVE]=Auxiliary.ToGraveFilter;
	[LOCATION_HAND]=Auxiliary.SearchFilter;
	[LOCATION_REMOVED]=Auxiliary.BanishFilter;
}
Glitchy.SendtoHints={
	[LOCATION_DECK]=HINTMSG_TODECK;
	[LOCATION_GRAVE]=HINTMSG_TOGRAVE;
	[LOCATION_HAND]=HINTMSG_RTOHAND;
	[LOCATION_REMOVED]=HINTMSG_REMOVE;
}
Glitchy.SendtoCategories={
	[LOCATION_DECK]=CATEGORY_TODECK;
	[LOCATION_GRAVE]=CATEGORY_TOGRAVE;
	[LOCATION_HAND]=CATEGORY_TOHAND;
	[LOCATION_REMOVED]=CATEGORY_REMOVE;
}
Glitchy.SendtoActions={
	[LOCATION_DECK]=function(g,e,tp,seq,p)
		seq=seq and seq or SEQ_DECKSHUFFLE
		Duel.SendtoDeck(g,p,seq,REASON_EFFECT)
	end;
	[LOCATION_GRAVE]=function(g)
		Duel.SendtoGrave(g,REASON_EFFECT)
	end;
	[LOCATION_HAND]=function(g,e,tp,p)
		Duel.SendtoHand(g,p,REASON_EFFECT)
	end;
	[LOCATION_REMOVED]=function(g,e,tp,pos)
		Duel.Remove(g,pos,REASON_EFFECT)
	end;
}
function Glitchy.SendtoAuxiliaryFunction(destination,f)
	local destf=xgl.SendtoFilters[destination](f)
	local hint=xgl.SendtoHints[destination]
	local category=xgl.SendtoCategories[destination]
	local action=xgl.SendtoActions[destination]
	return destf,hint,category,action
end
function Glitchy.SendtoTarget(destination,tgchk,f,loc1,loc2,min,max,exc,...)
	loc1=loc1 or 0
	loc2=loc2 or 0
	min=min or 1
	max=max or min
	local locs=loc1|loc2
	local f,hint,category=xgl.SendtoAuxiliaryFunction(destination,f)
	if not tgchk then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local exc=exc and e:GetHandler() or nil
					if chk==0 then
						return ft>=min and Duel.IsExists(false,f,tp,loc1,loc2,min,exc,e,tp)
					end
					local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
					Duel.SetOperationInfo(0,category,nil,min,players,locs)
				end
	
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					local exc=exc and e:GetHandler() or nil
					if chkc then
						return xgl.CreateChkc(chkc,e,tp,loc1,loc2,exc,f,e,tp)
					end
					if chk==0 then
						return Duel.IsExists(true,f,tp,loc1,loc2,min,exc,e,tp)
					end
					local g=Duel.Select(hint,true,tp,f,tp,loc1,loc2,min,max,exc,e,tp)
					if #g>0 then
						Duel.SetOperationInfo(0,category,g,#g,0,0)
					else
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,category,nil,min,players,locs)
					end
				end
	end
end

function Glitchy.SendtoOperation(destination,tgcheck,f,loc1,loc2,min,max,exc,...)
	local extras={...}
	loc1=loc1 or 0
	loc2=loc2 or 0
	local f,hint,_,CardActionFunction=xgl.SendtoAuxiliaryFunction(destination,f)
	if not tgcheck then
		min=min or 1
		max=max or min
		local locs=loc1|loc2
		
		if locs&LOCATION_GRAVE>0 then
			f=aux.Necro(f)
		end
		
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local exc=exc and e:GetHandler() or nil
					local g=Duel.Select(hint,false,tp,f,tp,loc1,loc2,min,max,exc,e,tp)
					if #g>=min then
						CardActionFunction(g,e,tp,table.unpack(extras))
					end
				end
					
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local og=Duel.GetTargetCards()
					local res,g=xgl.CheckTargetsAtResolution(tgcheck,loc1,loc2,tp,og,f,e,tp)
					if res then
						CardActionFunction(g,e,tp,table.unpack(extras))
					end
				end
	end
end

--Template for effects that Set Spells/Traps
function Glitchy.SSetTarget(tgchk,f,loc1,loc2,min,max,exc)
	loc1=loc1 or 0
	loc2=loc2 or 0
	min=min or 1
	max=max or min
	local locs=loc1|loc2
	f=aux.SSetFilter(f)
	if not tgchk then
		return	function(e,tp,eg,ep,ev,re,r,rp,chk)
					local exc=exc and e:GetHandler() or nil
					if chk==0 then
						return Duel.IsExists(false,f,tp,loc1,loc2,min,exc,e,tp)
					end
					if locs==LOCATION_GRAVE then
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,min,players,0)
					end
				end
	
	else
		return	function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
					local exc=exc and e:GetHandler() or nil
					if chkc then
						return xgl.CreateChkc(chkc,e,tp,loc1,loc2,exc,f,e,tp)
					end
					if chk==0 then
						return Duel.IsExists(true,f,tp,loc1,loc2,min,exc,e,tp)
					end
					local g=Duel.Select(HINTMSG_SET,true,tp,f,tp,loc1,loc2,min,max,exc,e,tp)
					local tg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
					if #tg>0 then
						Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
					elseif locs==LOCATION_GRAVE then
						local players=(loc1*loc2~=0) and PLAYER_ALL or loc1>0 and tp or 1-tp
						Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,min,players,0)
					end
				end
	end
end

function Glitchy.SSetOperation(setmod,tgcheck,f,loc1,loc2,min,max,exc)
	if not loc1 and not loc2 then Debug.Message("Undefined locations when calling Glitchy.SpecialSummonOperation") return end
	loc1=loc1 or 0
	loc2=loc2 or 0
	local setfunc,setparams=nil,{}
	if type(f)=="number" then
		tgcheck,f,loc1,loc2,min,max,exc = setmod,tgcheck,f,loc1,loc2,min,max
	else
		if type(setmod)=="table" then
			setfunc=setmod[1]
			if #setmod>=2 then
				for i=2,#setmod do
					table.insert(setparams,setmod[i])
				end
			end
		else
			setfunc=setmod
		end
	end
	f=aux.SSetFilter(f)
	if not tgcheck then
		min=min or 1
		max=max or min
		local locs=loc1|loc2
		
		if locs&LOCATION_GRAVE>0 then
			f=aux.Necro(f)
		end
		
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local exc=exc and e:GetHandler() or nil
					local g=Duel.Select(HINTMSG_SET,false,tp,f,tp,loc1,loc2,min,max,exc,e,tp)
					if #g>=min then
						if not setmod then
							Duel.SSet(tp,g)
						else
							setmod(tp,g,e,table.unpack(setparams))
						end
					end
				end
					
	else
		return	function(e,tp,eg,ep,ev,re,r,rp)
					local og=Duel.GetTargetCards()
					local res,g=xgl.CheckTargetsAtResolution(tgcheck,loc1,loc2,tp,og,f,e,tp)
					if res then
						if not setmod then
							Duel.SSet(tp,g)
						else
							setmod(tp,g,e,table.unpack(setparams))
						end
					end
				end
	end
end

--Special Summon self template: Special Summon "this card"
--[[Parameters
1) redirect = Redirect the card to the specified location when it leaves the field
]]
function Glitchy.SpecialSummonSelfTarget()
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local c=e:GetHandler()
				if chk==0 then
					return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
				end
				Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
			end
end
function Glitchy.SpecialSummonSelfOperation(redirect)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				local c=e:GetHandler()
				if c:IsRelateToChain() then
					if redirect then
						Duel.SpecialSummonRedirect(redirect,e,c,0,tp,tp,false,false,POS_FACEUP)
					else
						Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			end
end