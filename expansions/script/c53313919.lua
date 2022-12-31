--Mysterious Accel Dragon
function c53313919.initial_effect(c)
	--Materials: 1 Tuner + 1 non-Tuner monster
	aux.AddSynchroProcedure2(c,nil,aux.NonTuner(nil))
	c:EnableReviveLimit()
	--If this card is Synchro Summoned using a Pandemonium Monster as Material: You can target 1 "Mysterious" card in your GY; add it to your hand, and if you do, you can make this card's Level become equal to that monster's OR increase this card's Level by that monster's. (HOPT1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetCountLimit(1,53313919)
	e2:SetCondition(c53313919.thcon)
	e2:SetTarget(c53313919.thtg)
	e2:SetOperation(c53313919.thop)
	c:RegisterEffect(e2)
	--During your Main Phase: You can place 1 Pandemonium Monster from your hand into the Pandemonium Zone. (HOPT2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,53313920)
	e3:SetTarget(c53313919.patg)
	e3:SetOperation(c53313919.paop)
	c:RegisterEffect(e3)
end
function c53313919.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(Card.IsType,1,nil,TYPE_PANDEMONIUM)
end
function c53313919.tgfilter(c)
	return c:IsAbleToHand() and c:IsSetCard(0xcf6)
end
function c53313919.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53313919.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c53313919.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,c53313919.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function c53313919.thop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetFirstTarget()
	if sg:IsRelateToEffect(e) and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		local c=e:GetHandler()
		if sg:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsRelateToEffect(e) then
			local op=Duel.SelectOption(tp,1214,567,1370)
			if op==1 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetValue(sg:GetLevel())
				e1:SetReset(RESET_EVENT+0x1fe0000)
				c:RegisterEffect(e1)
			elseif op==2 then
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_UPDATE_LEVEL)
				e2:SetValue(sg:GetLevel())
				e2:SetReset(RESET_EVENT+0x1fe0000)
				c:RegisterEffect(e2)
			end
		end
	end
end
function c53313919.patg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,nil,TYPE_PANDEMONIUM) and aux.PandActCon(e,tp) end
end
function c53313919.paop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not aux.PandActCon(e,tp) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,nil,TYPE_PANDEMONIUM)
	local tc=g:GetFirst()
	if tc then
		aux.PandAct(tc)(e,tp,eg,ep,ev,re,r,rp)
	end
end
