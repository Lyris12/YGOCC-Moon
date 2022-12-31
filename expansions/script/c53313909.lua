	--Mysterious Ferret
function c53313909.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--You can destroy this card, then Special Summon 1 level 6 or lower "Mysterious" monster from your Deck, except "Mysterious Ferret". You can only use this effect of "Mysterious Ferret" once per turn.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_QUICK_O)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetRange(LOCATION_SZONE)
	e0:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e0:SetCondition(aux.PandActCheck)
	e0:SetTarget(c53313909.rptg)
	e0:SetOperation(c53313909.rpop)
	c:RegisterEffect(e0)
	aux.EnablePandemoniumAttribute(c,e0)
	--This card can attack your opponent directly.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--If this card inflicts battle damage to your opponent by a direct attack: You can add 1 face-up "Mysterious" Pandemonium Monster from your Extra Deck to your hand, except "Mysterious Ferret", and if you do, Special Summon 1 Level 4 or lower "Mysterious" monster from your hand. You can only use this effect of "Mysterious Ferret" once per turn.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,53313908)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetCondition(c53313909.pcon)
	e2:SetTarget(c53313909.ptg)
	e2:SetOperation(c53313909.pop)
	c:RegisterEffect(e2)
end
function c53313909.rpfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsSetCard(0xcf6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(53313909)
end
function c53313909.rptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c53313909.rpfilter,tp,LOCATION_DECK,0,1,nil,e,tp) and Duel.GetFlagEffect(tp,53313909)==0 end
	Duel.RegisterFlagEffect(tp,53313909,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_DECK)
end
function c53313909.rpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,c53313909.rpfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function c53313909.pcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetAttackTarget()==nil
end
function c53313909.pfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM) and c:IsSetCard(0xcf6) and not c:IsCode(53313909) and c:IsAbleToHand()
end
function c53313909.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xcf6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c53313909.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313909.pfilter,tp,LOCATION_EXTRA,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c53313909.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c53313909.pop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c53313909.pfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		Duel.ConfirmCards(1-tp,g)
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,c53313909.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if sg:GetCount()>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
