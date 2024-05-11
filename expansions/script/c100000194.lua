--[[
Crystal Chimera
Chimera di Cristallo
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If this card is in your hand, and the total Levels of all Beast monsters you control is 6 or higher (Quick Effect):
	You can target 1 monster your opponent controls; Special Summon this card, and if you do, destroy that target, then immediately after this effect resolves,
	you can Synchro, Xyz, Link, Bigbang or Time Leap Summon 1 Beast monster using Beast monsters you control.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetFunctions(s.condition,nil,s.target,s.operation)
	c:RegisterEffect(e1)
	--[[You can banish this card from your GY, then discard 1 Beast monster; draw 2 cards.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(nil,s.drawcost,s.drawtg,s.drawop)
	c:RegisterEffect(e2)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:HasLevel()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,nil):GetSum(Card.GetLevel)>=6
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExists(true,nil,tp,0,LOCATION_MZONE,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local g=Duel.Select(HINTMSG_DESTROY,true,tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.matfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0) then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsControler(1-tp) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		if Duel.IsExists(false,s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.SelectYesNo(tp,STRING_ASK_SPSUMMON) then
			local sc=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
			if not sc then return end
			Duel.BreakEffect()
			if sc:IsType(TYPE_SYNCHRO) then
				local mg=aux.GetSynMaterials(tp,sc):Filter(Card.IsRace,nil,RACE_BEAST)
				Duel.SynchroSummon(tp,sc,nil,mg)
		
			elseif sc:IsType(TYPE_XYZ) then
				local mg=Duel.Group(aux.XyzLevelFreeFilter,tp,LOCATION_MZONE,0,nil,sc):Filter(Card.IsRace,nil,RACE_BEAST)
				Duel.XyzSummon(tp,sc,mg,1,#mg)
			
			elseif sc:IsType(TYPE_LINK) then
				local mg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,RACE_BEAST),tp,LOCATION_MZONE,0,nil)
				local eid=e:GetFieldID()
				for tc in aux.Next(mg) do
					tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE,1,eid)
				end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
				e1:SetTargetRange(0xff,0xff)
				e1:SetTarget(s.limitmat)
				e1:SetLabel(eid)
				e1:SetValue(1)
				local e0=Effect.CreateEffect(c)
				e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
				e0:SetCode(EVENT_SPSUMMON)
				e0:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
					e1:Reset()
					_e:Reset()
				end
				)
				Duel.RegisterEffect(e0,tp)
				Duel.LinkSummon(tp,sc,mg)
			
			elseif sc:IsType(TYPE_BIGBANG) then
				local mg=Duel.GetMatchingGroup(Card.IsCanBeBigbangMaterial,tp,LOCATION_MZONE,0,nil,c):Filter(Card.IsRace,nil,RACE_BEAST)
				local mg2=Duel.GetMatchingGroup(Auxiliary.BigbangExtraFilter,tp,0xff,0xff,nil,sc,tp)
				mg:Merge(mg2)
				local eid=e:GetFieldID()
				for tc in aux.Next(mg) do
					tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE,1,eid)
				end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
				e1:SetTargetRange(0xff,0xff)
				e1:SetTarget(s.limitmat)
				e1:SetLabel(eid)
				e1:SetValue(1)
				local e1x=e1:Clone()
				bigbang_limit_mats_condition = e1
				bigbang_limit_mats_operation = e1x
				Duel.SpecialSummonRule(tp,sc,340)
				if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
				
			elseif sc:IsType(TYPE_TIMELEAP) then
				local mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterial,tp,LOCATION_MZONE,0,nil,c):Filter(aux.Faceup(Card.IsRace),nil,RACE_BEAST)
				local mg2=Duel.GetMatchingGroup(Auxiliary.TimeleapExtraFilter,tp,0xff,0xff,nil,nil,c,tp)
				mg:Merge(mg2)
				local eid=e:GetFieldID()
				for tc in aux.Next(mg) do
					tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE,1,eid)
				end
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_BE_TIMELEAP_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
				e1:SetTargetRange(0xff,0xff)
				e1:SetTarget(s.limitmat)
				e1:SetLabel(eid)
				e1:SetValue(1)
				local e0=Effect.CreateEffect(c)
				e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
				e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
				e0:SetCode(EVENT_SPSUMMON)
				e0:SetOperation(function(_e,_tp,_eg,_ep,_ev,_re,_r,_rp)
					e1:Reset()
					_e:Reset()
				end
				)
				Duel.RegisterEffect(e0,tp)
				Duel.SpecialSummonRule(tp,sc,SUMMON_TYPE_TIMELEAP)
				if Duel.SetSummonCancelable then Duel.SetSummonCancelable(false) end
			end
		end
	end
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST)
		and (s.synfilter(c,tp) or s.xyzfilter(c,tp) or s.lnkfilter(c,tp) or s.bbgfilter(c,e,tp) or s.tmlfilter(c,e,tp))
end
function s.synfilter(c,tp)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	local mg=aux.GetSynMaterials(tp,c):Filter(Card.IsRace,nil,RACE_BEAST)
	return c:IsSynchroSummonable(nil,mg)
end
function s.xyzfilter(c,tp)
	if not c:IsType(TYPE_XYZ) then return false end
	local mg=Duel.Group(aux.XyzLevelFreeFilter,tp,LOCATION_MZONE,0,nil,c):Filter(Card.IsRace,nil,RACE_BEAST)
	return c:IsXyzSummonable(mg)
end
function s.lnkfilter(c,tp)
	if not c:IsType(TYPE_LINK) then return false end
	local res=false
	local eset=c:GetEffects()
	for i,ce in ipairs(eset) do
		if ce and not ce:WasReset(c) then
			if ce:GetCode()==EFFECT_SPSUMMON_PROC then
				local sumtyp=0
				local val=ce:GetValue()
				if type(val)=="function" then
					sumtyp=val(ce,c)
				else
					sumtyp=val
				end
				if sumtyp==SUMMON_TYPE_LINK then
					local mg=Auxiliary.GetLinkMaterials(tp,nil,c,ce):Filter(Card.IsRace,nil,RACE_BEAST)
					if c:IsLinkSummonable(mg) then
						res=true
						break
					end
				end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return res
end
function s.bbgfilter(c,e,tp)
	if not c:IsType(TYPE_BIGBANG) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_BIGBANG,tp,false,false) then return false end
	local mg=Duel.GetMatchingGroup(Card.IsCanBeBigbangMaterial,tp,LOCATION_MZONE,0,nil,c):Filter(Card.IsRace,nil,RACE_BEAST)
	local mg2=Duel.GetMatchingGroup(Auxiliary.BigbangExtraFilter,tp,0xff,0xff,nil,c,tp)
	mg:Merge(mg2)
	if Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local res=false
	local eset=c:GetEffects()
	for i,ce in ipairs(eset) do
		if ce and not ce:WasReset(c) then
			if ce:GetCode()==EFFECT_SPSUMMON_PROC then
				local ev=ce:GetValue()
				local ec=ce:GetCondition()
				if ev and (aux.GetValueType(ev)=="function" and ev(ce,c)&340==340 or ev&340==340) and (not ec or ec(ce,c,mg,nil)) then return true end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return res
end
function s.tmlfilter(c,e,tp)
	if not c:IsType(TYPE_TIMELEAP) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_TIMELEAP,tp,false,false) then return false end
	local mg=Duel.GetMatchingGroup(Card.IsCanBeTimeleapMaterial,tp,LOCATION_MZONE,0,nil,c):Filter(aux.Faceup(Card.IsRace),nil,RACE_BEAST)
	local mg2=Duel.GetMatchingGroup(Auxiliary.TimeleapExtraFilter,tp,0xff,0xff,nil,nil,c,tp)
	mg:Merge(mg2)
	if Duel.GetLocationCountFromEx(tp,tp,mg,c)<=0 then return false end
	local res=false
	local eset=c:GetEffects()
	for i,ce in ipairs(eset) do
		if ce and not ce:WasReset(c) then
			if ce:GetCode()==EFFECT_SPSUMMON_PROC then
				local ev=ce:Evaluate(c)
				local ec=ce:GetCondition()
				if ev and ev&SUMMON_TYPE_TIMELEAP==SUMMON_TYPE_TIMELEAP and (not ec or ec(ce,c,mg)) then
					return true
				end
			end
		else
			aux.MarkResettedEffect(c,i)
		end
	end
	aux.DeleteResettedEffects(c)
	return res
end
function s.limitmat(e,c)
	return not c:HasFlagEffectLabel(id,e:GetLabel())
end

--E2
function s.dcfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsDiscardable()
end
function s.drawcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExists(false,s.dcfilter,tp,LOCATION_HAND,0,1,nil)
	end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.DiscardHand(tp,s.dcfilter,1,1,REASON_COST|REASON_DISCARD)
end
function s.drawtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.drawop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end