--Maresciallo Proxima
--Script by XGlitchy30
function c63553468.initial_effect(c)
	--synchro summon
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,c63553468.matfilter1,nil,nil,aux.NonTuner(nil),1,99)
	--no tuner check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(80896940)
	c:RegisterEffect(e1)
	--choose effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c63553468.condition)
	e2:SetTarget(c63553468.target)
	e2:SetOperation(c63553468.operation)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c63553468.sptg)
	e3:SetOperation(c63553468.spop)
	c:RegisterEffect(e3)
end
--filters
function c63553468.matfilter1(c,syncard)
	return (c:IsType(TYPE_TUNER) and (c:IsType(TYPE_PENDULUM) or c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM))
		or ((c:IsType(TYPE_PENDULUM) or c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM) and c:IsNotTuner(syncard))
end
function c63553468.thfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
function c63553468.setfilter(c)
	return c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
end
function c63553468.spfilter(c,e,tp)
	return c:IsFaceup() and c:GetLevel()<=4 and (c:IsType(TYPE_PENDULUM) or c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--choose effect
function c63553468.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function c63553468.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local sel=0
		if Duel.IsExistingMatchingCard(c63553468.thfilter,tp,LOCATION_EXTRA,0,1,nil) then sel=sel+1 end
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandSSetCon(c63553468.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp) and Duel.IsExistingMatchingCard(c63553468.setfilter,tp,LOCATION_DECK,0,1,nil) then sel=sel+2 end
		e:SetLabel(sel)
		return sel~=0
	end
	local sel=e:GetLabel()
	local op=0
	if sel==3 then
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40044918,0))
		op=Duel.SelectOption(tp,aux.Stringid(63553468,0),aux.Stringid(63553468,1))
	elseif sel==1 then
		op=Duel.SelectOption(tp,aux.Stringid(63553468,0))
	else
		op=Duel.SelectOption(tp,aux.Stringid(63553468,1))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	end
end
function c63553468.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c63553468.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		if g:GetCount()>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not aux.PandSSetCon(c63553468.setfilter,nil,LOCATION_DECK)(nil,e,tp,eg,ep,ev,re,r,rp) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.PandSSetFilter(c63553468.setfilter),tp,LOCATION_DECK,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			aux.PandSSet(tc,REASON_EFFECT,aux.GetOriginalPandemoniumType(tc))(e,tp,eg,ep,ev,re,r,rp)
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
--special summon
function c63553468.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCountFromEx(tp)>0
		and Duel.IsExistingMatchingCard(c63553468.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c63553468.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCountFromEx(tp)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c63553468.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
