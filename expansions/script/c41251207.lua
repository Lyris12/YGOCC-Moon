--Savior of the Daylilly
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	
	c:EnableReviveLimit()
	aux.EnablePendulumAttribute(c,false)
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_PLANT),aux.NonTuner(s.mfilter),1)
	--double original def
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS},s.filter,id,LOCATION_PZONE,nil,LOCATION_PZONE,nil,id+100,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CUSTOM+s.progressive_id)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT(true)
	e3:SetLabel(0)
	e3:SetCondition(s.spcon)
	e3:SetCost(aux.DummyCost)
	e3:SetTarget(s.sptg3)
	e3:SetOperation(s.spop3)
	c:RegisterEffect(e3)
	--place in pzone
	aux.AddDaylillyPlacingEffect(c,s.pencon,true)
end
function s.mfilter(c)
	return c:IsRace(RACE_PLANT) and not c:IsSynchroType(TYPE_EFFECT)
end

function s.filter(c,_,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_HAND|LOCATION_GRAVE) and c:IsFaceup() and c:IsRace(RACE_PLANT)
end
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_BLACK_GARDEN),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	if eg then
		local c=e:GetHandler()
		local g
		local sg=eg:Filter(aux.NOT(Card.HasFlagEffectLabel),nil,id+200,c:GetFieldID())
		if #sg>1 then
			g=sg:SelectSubGroup(tp,aux.SimultaneousEventGroupCheck,false,1,#sg,id+100,sg)
		else
			g=sg:Clone()
		end
		Duel.HintSelection(g)
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(id+200,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1,c:GetFieldID())
		end
		Duel.SetTargetCard(g)
	end
end
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if not g then return end
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		e1:SetValue(tc:GetBaseDefense()*2)
		tc:RegisterEffect(e1)
	end
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_BLACK_GARDEN),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.fgoal(g,e,tp)
	return Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp,g)
end
function s.spfilter3(c,e,tp,g,lv)
	if not (c:IsFaceupEx() and c:IsMonster(TYPE_FUSION) and c:IsRace(RACE_PLANT) and c:GetLevel()>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)) then return false end

	if g then
		if not g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),#g,#g) then
			return false
		end
	elseif lv then
		if not c:IsLevel(lv) then
			return false
		end
	end
	
	if c:IsInGY() then
		return Duel.GetMZoneCount(tp,g,tp,LOCATION_REASON_TOFIELD,0x1f)>0
	else
		return Duel.GetLocationCountFromEx(tp,tp,g,c,0x1f)>0
	end
end
function s.cfilter1(c,tp)
	return not c:IsType(TYPE_EFFECT) and c:IsRace(RACE_PLANT) and (c:IsFaceup() or c:IsControler(tp)) and c:GetLevel()>0
end
function s.lairfilter_forced(c,tp,g)
	return c:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp) and not g:IsContains(c)
end
function s.lairfilter_optional(c,tp,g)
	return c:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp) and g:IsContains(c)
end
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetReleaseGroup(tp)
	local g2=Duel.Group(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	g1:Merge(g2)
	g1=g1:Filter(s.cfilter1,nil,tp)
	if chk==0 then
		return e:IsCostChecked() and #g1>0 and g1:CheckSubGroup(s.fgoal,1,#g1,e,tp)
	end
	Duel.HintMessage(tp,HINTMSG_RELEASE)
	local rg=g1:SelectSubGroup(tp,s.fgoal,false,1,#g1,e,tp)
	e:SetLabel(rg:GetSum(Card.GetLevel))
	
	local exg=rg:Filter(Auxiliary.ExtraReleaseFilter,nil,tp)
	local exg1=exg:Filter(s.lairfilter_forced,nil,tp,g2)
	local exg2=exg:Filter(s.lairfilter_optional,nil,tp,g2)
	local te
	if #exg1>0 then
		local tc=exg1:Select(tp,1,1,nil):GetFirst()
		te=tc:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp)
	elseif #exg2>0 and Duel.SelectYesNo(tp,STRING_ASK_EXTRA_RELEASE_NONSUM) then
		local tc=exg2:Select(tp,1,1,nil):GetFirst()
		te=tc:IsHasEffect(EFFECT_EXTRA_RELEASE_NONSUM,tp)
	end
	if te then
		Duel.Hint(HINT_CARD,tp,te:GetHandler():GetOriginalCode())
		te:UseCountLimit(tp)
	end
	Duel.Release(rg,REASON_COST)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	if not lv then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter3),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp,nil,lv):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,0x1f)
	end
end

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_EFFECT|REASON_BATTLE)>0
end