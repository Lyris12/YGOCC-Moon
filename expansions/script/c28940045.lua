--Astralost Duskwalker
local ref,id=GetID()
Duel.LoadScript("Astralost.lua")
function ref.initial_effect(c)
	aux.EnablePendulumAttribute(c,true)
	--Fusion
	local pe1=Effect.CreateEffect(c)
	pe1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK)
	pe1:SetType(EFFECT_TYPE_IGNITION)
	pe1:SetCode(EVENT_FREE_CHAIN)
	pe1:SetRange(LOCATION_PZONE)
	pe1:SetCountLimit(1)
	pe1:SetTarget(ref.fustg)
	pe1:SetOperation(ref.fusop)
	c:RegisterEffect(pe1)
	--Return
	local e1=Astralost.CreateHealTrigger(c,id)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return e:GetHandler():IsAbleToHand() end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_GRAVE) end)
	e1:SetOperation(function(e) local c=e:GetHandler()
		if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end end)
	c:RegisterEffect(e1)
	--Place
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCondition(function(e) local c=e:GetHandler()
		return c:IsLocation(LOCATION_EXTRA) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup() end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) local c=e:GetHandler()
		if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)) and not c:IsForbidden() end end)
	e2:SetOperation(function(e,tp) local c=e:GetHandler()
		if c:IsRelateToEffect(e) then Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true) end end)
	c:RegisterEffect(e2)
end

--Fusion
function ref.matfilter(c,e)
	return c:IsCanBeFusionMaterial() and not c:IsImmuneToEffect(e)
end
function ref.fusfilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:CheckFusionMaterial(mg,nil,tp)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
end
function ref.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		mg:Merge(Duel.GetMatchingGroup(ref.matfilter,tp,LOCATION_PZONE,0,nil,e))
		return Duel.IsExistingMatchingCard(ref.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function ref.fusop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local mg=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
	mg:Merge(Duel.GetMatchingGroup(ref.matfilter,tp,LOCATION_PZONE,0,nil,e))
	local fg=Duel.SelectMatchingCard(tp,ref.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,mg)
	if #fg>0 then
		local fc=fg:GetFirst()
		local mat=Duel.SelectFusionMaterial(tp,fc,mg,c,tp)
		fc:SetMaterial(mat)
		if mat:IsExists(Card.IsFacedown,1,nil) then
			local cg=mat:Filter(Card.IsFacedown,nil)
			Duel.ConfirmCards(1-tp,cg)
		end
		Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
		Duel.SpecialSummon(fc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	end
end