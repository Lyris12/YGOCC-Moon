--Mysterious Cosmic Dragon
function c53313917.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--If a monster(s) you control would be destroyed by battle or an opponent’s card effect, you can destroy this card instead. (OPT)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c53313917.reptg)
	e1:SetValue(c53313917.repval)
	e1:SetOperation(c53313917.repop)
	c:RegisterEffect(e1)
	--If a monster(s) you control is destroyed by battle or an opponent’s card effect: You can add 1 Level 7 or lower “Mysterious” monster from your Deck or GY to your hand. (OPT)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(c53313917.cfilter) end)
	e2:SetTarget(c53313917.thtg)
	e2:SetOperation(c53313917.thop)
	c:RegisterEffect(e2)
	aux.EnablePandemoniumAttribute(c,e2,false,TYPE_EFFECT+TYPE_SYNCHRO)
	--spsummon
	c:EnableReviveLimit()
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xCF6),aux.NonTuner(nil),1)
	--actlimit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c53313917.aclimit)
	e3:SetCondition(c53313917.actcon)
	c:RegisterEffect(e3)
	--Once per turn: You can target 1 "Mysterious" monster on the field with a Level lower than this card's; until the end of this turn, this card gains that monster's original effects.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53313917,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c53313917.remtg)
	e2:SetOperation(c53313917.remop)
	c:RegisterEffect(e2)
	--If this card in the Monster Zone is destroyed by battle or card effect: You can Set it into your Spell/Trap Zone.
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCondition(function(e,tp,eg,ep,eg,re,r,rp) local c=e:GetHandler() return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) end)
	e4:SetTarget(c53313917.sttg)
	e4:SetOperation(c53313917.stop)
	c:RegisterEffect(e4)
end
function c53313917.filter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT)))
end
function c53313917.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.PandActCheck(e) and eg:IsExists(c53313917.filter,1,nil,tp) and c:GetFlagEffect(53313917)==0
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function c53313917.repval(e,c)
	return c53313917.filter(c,e:GetHandlerPlayer())
end
function c53313917.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
function c53313917.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsControler() and (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()~=tp and c:IsReason(REASON_EFFECT)))
end
function c53313917.thfilter(c)
	return c:IsSetCard(0xcf6) and c:IsType(TYPE_MONSTER) and c:IsLevelBelow(7) and c:IsAbleToHand()
end
function c53313917.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(53313917)==0
		and Duel.IsExistingMatchingCard(c53313917.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	e:GetHandler():RegisterEffect(53313917,RESET_EVENT+0x1fe000+RESET_PHASE+PHASE_END)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function c53313917.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c53313917.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function c53313917.aclimit(e,re,tp)
	return not re:GetHandler():IsImmuneToEffect(e)
end
function c53313917.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
function c53313917.rfilter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0xcf6) and c:IsLevelBelow(lv-1)
end
function c53313917.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c and c53313917.rfilter(chkc,c:GetLevel()) end
	if chk==0 then return Duel.IsExistingTarget(c53313917.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c:GetLevel()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c53313917.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,c:GetLevel())
end
function c53313917.remop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c:IsRelateToEffect(e) and c:IsFaceup() then
		c:CopyEffect(tc:GetOriginalCode(),RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END)
	end
end
function c53313917.sttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and aux.PandSSetCon(e:GetHandler(),nil,e:GetHandler():GetLocation(),e:GetHandler():GetLocation())(nil,e,tp,eg,ep,ev,re,r,rp) end
end
function c53313917.stop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandSSetCon(e:GetHandler(),nil,e:GetHandler():GetLocation(),e:GetHandler():GetLocation())(nil,e,tp,eg,ep,ev,re,r,rp) then
		aux.PandSSet(tc,REASON_EFFECT,TYPE_EFFECT+TYPE_SYNCHRO)(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,tc)
	end
end
