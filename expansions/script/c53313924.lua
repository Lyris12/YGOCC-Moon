--Mysterious Tornado Dragon
function c53313924.initial_effect(c)
	--fusion material: 1 "Mysterious" Dragon Monster + 1 WIND Winged Beast Monster.
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,c53313924.matfilter1,c53313924.matfilter2,true)
	--If this card is Fusion Summoned: Return all Spell/Traps on the field to the hand.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetTarget(c53313924.destg)
	e1:SetOperation(c53313924.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Once per turn: You can Tribute 1 other monster you control and target 1 monster your opponent controls; banish that target, and if you do, this card gains ATK and DEF equal to it's original Level x100, until the end of this turn.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e3:SetCost(c53313924.rmcost)
	e3:SetTarget(c53313924.rmtg)
	e3:SetOperation(c53313924.rmop)
	c:RegisterEffect(e3)
	--You can target 1 monster from your GY or face-up in your Extra Deck; banish it, and if you do, this card gains that monster's original effects until the end of this turn. (HOPT)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,53313924)
	e4:SetCost(c53313924.cost)
	e4:SetOperation(c53313924.copy)
	c:RegisterEffect(e4)
end
function c53313924.matfilter1(c)
	return c:IsSetCard(0xCF6) and c:IsRace(RACE_DRAGON)
end
function c53313924.matfilter2(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WINDBEAST)
end
function c53313924.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
function c53313924.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function c53313924.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsControler,1,e:GetHandler(),tp) end
	local sg=Duel.SelectReleaseGroup(tp,Card.IsControler,1,1,e:GetHandler(),tp)
	Duel.Release(sg,REASON_COST)
end
function c53313924.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsLevelAbove(1) end
	if chk==0 then return Duel.IsExistingTarget(c53313924.rmfilter,tp,0,LOCATION_MZONE,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c53313924.rmfilter,tp,0,LOCATION_MZONE,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c53313924.rmfilter(c,e)
	return c:IsLevelAbove(1) and not c:IsImmuneToEffect(e) and c:IsAbleToRemove()
end
function c53313924.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFirstTarget()
	if g:IsRelateToEffect(e) and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local lv=g:GetOriginalLevel()
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(lv*100)
		e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
function c53313924.rfilter(c)
	return (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function c53313924.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313924.rfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c53313924.rfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
end
function c53313924.copy(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() then
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
	end
end
