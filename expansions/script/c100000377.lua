--[[
Curseflame Abyssal Rite
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Activate 1 of these effects:
	● Ritual Summon 1 DARK Ritual Monster from your hand, by Tributing monsters from your hand or field whose total Levels/Ranks/Link Ratings/Futures exactly equal the Level of that Ritual Monster.
	You can also use monsters your opponent controls with Curseflame Counters on them as Tributes for that Ritual Summon.
	● Banish 2 "Curseflame" monsters from your hand, Deck, and/or GY with different names; distribute Curseflame Counters among face-up cards on the field, equal to the combined Levels/Ranks/Link
	Ratings/Futures/Sealed Levels of those banished monsters.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:HOPT()
	e1:SetFunctions(nil,aux.DummyCost,s.target,s.activate)
	c:RegisterEffect(e1)
	--[[If this card is in your GY while there are 3 or more Curseflame Counters on the field: You can banish this card and 1 Level 5 "Curseflame" monster from the GY, then target 1 face-up card on
	the field; place Curseflame Counters on that target, equal to the total number of Curseflame Counters currently on the field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,3)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		s.ctcon,
		s.ctcost,
		s.cttg,
		s.ctop
	)
	c:RegisterEffect(e2)
end
--E1
function s.matlevelfunc(c,rc)
	if c:HasLevel() then
		return c:GetRitualLevel(rc)
	end
	if c:IsOriginalType(TYPE_XYZ) then
		return c:GetRank()
	end
	if c:IsOriginalType(TYPE_LINK) then
		return c:GetLink()
	end
	if c:IsOriginalType(TYPE_TIMELEAP) then
		return c:GetFuture()
	end
	return 0
end
function s.RitualCheck(g,tp,c,lv)
	return g:CheckWithSumEqual(s.matlevelfunc,lv,#g,#g,c) and Duel.GetMZoneCount(tp,g,tp)>0 and (not c.mat_group_check or c.mat_group_check(g,tp))
		and (not Auxiliary.RCheckAdditional or Auxiliary.RCheckAdditional(tp,g,c))
end
function s.RitualCheckAdditionalLevel(c,rc)
	local raw_level=s.matlevelfunc(c,rc)
	local lv1=raw_level&0xffff
	local lv2=raw_level>>16
	if lv2>0 then
		return math.min(lv1,lv2)
	else
		return lv1
	end
end
function s.RitualCheckAdditional(c,lv)
	return	function(g)
				return (not Auxiliary.RGCheckAdditional or Auxiliary.RGCheckAdditional(g)) and g:GetSum(s.RitualCheckAdditionalLevel,c)<=lv
			end
end
function s.RitualUltimateFilter(c,e,tp,m1,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or not c:IsAttribute(ATTRIBUTE_DARK) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local lv=c:GetLevel()
	Auxiliary.GCheckAdditional=s.RitualCheckAdditional(c,lv)
	local res=mg:CheckSubGroup(s.RitualCheck,1,lv,tp,c,lv)
	Auxiliary.GCheckAdditional=nil
	return res
end
function s.ritualmatex(c,e)
	return c:HasCounter(COUNTER_CURSEFLAME) and not c:IsImmuneToEffect(e) and c:IsReleasableByEffect()
end
function s.RitualUltimateTarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterialEx(tp)+Duel.Group(s.ritualmatex,tp,0,LOCATION_MZONE,nil,e)
		return Duel.IsExistingMatchingCard(s.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg,true)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetCustomOperationInfo(0,CATEGORY_SPSUMMON_RITUAL_MONSTER,nil,1,tp,LOCATION_HAND)
end
function s.RitualUltimateOperation(e,tp,eg,ep,ev,re,r,rp)
	::RitualUltimateSelectStart::
	local mg=Duel.GetRitualMaterialEx(tp)+Duel.Group(s.ritualmatex,tp,0,LOCATION_MZONE,nil,e)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg)
	local tc=tg:GetFirst()
	local mat
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local lv=tc:GetLevel()
		Auxiliary.GCheckAdditional=s.RitualCheckAdditional(tc,lv)
		mat=mg:SelectSubGroup(tp,s.RitualCheck,true,1,lv,tp,tc,lv)
		Auxiliary.GCheckAdditional=nil
		if not mat then goto RitualUltimateSelectStart end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	if extra_operation then
		extra_operation(e,tp,eg,ep,ev,re,r,rp,tc,mat)
	end
end
function s.rmfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_CURSEFLAME) and c:GetRatingAuto(RATING_LEVEL|RATING_RANK|RATING_LINK|RATING_FUTURE)>0 and c:IsAbleToRemoveAsCost()
end
function s.gcheck(rg,fg)
	if not aux.dncheck(rg) then return false end
	local ct=rg:GetSum(Card.GetRatingAuto,RATING_LEVEL|RATING_RANK|RATING_LINK|RATING_FUTURE)
	return fg:CheckSubGroup(aux.DistributeCountersGroupCheck(COUNTER_CURSEFLAME),1,#fg,ct)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.Group(s.rmfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil)
	local fg=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local b1=s.RitualUltimateTarget(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=e:IsCostChecked() and #fg>0 and rg:CheckSubGroup(s.gcheck,2,2,fg)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,id,1,b1,b2)
	if opt==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetCustomCategory(CATEGORY_SPSUMMON_RITUAL_MONSTER)
		s.RitualUltimateTarget(e,tp,eg,ep,ev,re,r,rp,chk)
		Duel.SetTargetParam(opt)
	elseif opt==1 then
		e:SetCategory(CATEGORY_COUNTER)
		e:SetCustomCategory(0)
		Duel.HintMessage(tp,HINTMSG_REMOVE)
		local rtg=rg:SelectSubGroup(tp,s.gcheck,false,2,2,fg)
		local ct=rtg:GetSum(Card.GetRatingAuto,RATING_LEVEL|RATING_RANK|RATING_LINK|RATING_FUTURE)
		Duel.Remove(rtg,POS_FACEUP,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,fg,ct,tp,COUNTER_CURSEFLAME)
		Duel.SetTargetParam(opt|(ct<<16))
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tgparam=Duel.GetTargetParam()
	local opt=tgparam&0xffff
	local ct=(tgparam>>16)&0xffff
	if opt==0 then
		s.RitualUltimateOperation(e,tp,eg,ep,ev,re,r,rp)
	elseif opt==1 then
		local g=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ActivateException(e,false))
		if #g>0 then
			Duel.DistributeCounters(tp,COUNTER_CURSEFLAME,ct,g,id)
		end
	end
end

--E2
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)>=3
end
function s.rcfilter(c)
	return c:IsSetCard(ARCHE_CURSEFLAME) and c:IsLevel(5) and c:IsAbleToRemoveAsCost()
end
function s.ctcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToRemoveAsCost() and Duel.IsExists(false,s.rcfilter,tp,LOCATION_GRAVE,0,1,c)
	end
	local g=Duel.Select(HINTMSG_REMOVE,false,tp,s.rcfilter,tp,LOCATION_GRAVE,0,1,1,c)
	Duel.Remove(g+c,POS_FACEUP,REASON_COST)
end
function s.ctfilter(c,ct)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_CURSEFLAME,ct)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	if chkc then return chkc:IsOnField() and s.ctfilter(chkc,ct) end
	if chk==0 then
		return ct>0 and Duel.IsExists(true,s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,ct)
	end
	local g=Duel.Select(HINTMSG_FACEUP,true,tp,s.ctfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,ct)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,ct,tp,COUNTER_CURSEFLAME)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetCounter(0,1,1,COUNTER_CURSEFLAME)
	if ct<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsCanAddCounter(COUNTER_CURSEFLAME,ct) then
		tc:AddCounter(COUNTER_CURSEFLAME,ct)
	end
end