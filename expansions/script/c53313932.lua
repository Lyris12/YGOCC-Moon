--Gelofoca Misteriosa
--Script by XGlitchy30
function c53313932.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xcf6),2,2)
	c:EnableReviveLimit()
	--add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53313932,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,53313932)
	e1:SetTarget(c53313932.thtg)
	e1:SetOperation(c53313932.thop)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e1x)
	local e1y=e1:Clone()
	e1y:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1y)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53313932,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53323932)
	e2:SetLabel(0)
	e2:SetCost(c53313932.spcost)
	e2:SetTarget(c53313932.sptg)
	e2:SetOperation(c53313932.spop)
	c:RegisterEffect(e2)
end
--filters
function c53313932.thfilter(c,e)
	return c:IsSetCard(0xcf6) and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
function c53313932.rfilter(c,e,tp)
	return Duel.IsExistingMatchingCard(c53313932.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,e:GetHandler(),e,tp,c:GetAttribute(),c:GetCode()) and Duel.GetMZoneCount(tp,c)>0
end
function c53313932.spfilter(c,e,tp,att,code)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsAttribute(att) and c:IsSetCard(0xcf6) and not c:IsCode(53313932) and not c:IsCode(code)
end
--add to hand
function c53313932.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313932.thfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,1,nil,e) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,0,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED)
end
function c53313932.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53313932.thfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA+LOCATION_REMOVED,0,1,1,nil,e)
	if #g==0 then return end
	local tc=g:GetFirst()
	local op=0
	if tc:IsType(TYPE_PANDEMONIUM) then
		local ac=0
		local con1=tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local con2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		local check=tc:IsLocation(LOCATION_EXTRA)
		local excon=Duel.GetLocationCountFromEx(tp)>0
		if (con1 and con2 and not check) or (check and excon and con1) then
			ac=Duel.SelectOption(tp,aux.Stringid(53313932,0),aux.Stringid(53313932,1))
		end
		if ac==0 then Duel.SendtoHand(tc,nil,REASON_EFFECT)
		else Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
	else Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
--spsummon
function c53313932.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function c53313932.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return Duel.CheckReleaseGroup(tp,c53313932.rfilter,1,nil,e,tp)
	end
	e:SetLabel(0)
	local g=Duel.SelectReleaseGroup(tp,c53313932.rfilter,1,1,nil,e,tp)
	Duel.Release(g,REASON_COST)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c53313932.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53313932.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp,tc:GetAttribute(),tc:GetCode())
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
