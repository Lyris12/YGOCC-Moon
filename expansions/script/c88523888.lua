--Kitseki Creature Bond
--Script by XGlitchy30
function c88523888.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c88523888.eqtg)
	e1:SetOperation(c88523888.eqop)
	c:RegisterEffect(e1)
	--Equip limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c88523888.eqlimit)
	c:RegisterEffect(e2)
	--ATK boost
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c88523888.atkcon)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c88523888.atktg)
	e3:SetValue(c88523888.atkval)
	c:RegisterEffect(e3)
	--deck destruction
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(88523888,0))
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c88523888.deckcon)
	e4:SetTarget(c88523888.decktg)
	e4:SetOperation(c88523888.deckop)
	c:RegisterEffect(e4)
	--effect destruction event
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(88523888,1))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c88523888.thcon)
	e5:SetTarget(c88523888.thtg)
	e5:SetOperation(c88523888.thop)
	c:RegisterEffect(e5)
end
--filters
function c88523888.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x215a)
end
function c88523888.battle(c,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc
end
function c88523888.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x215a) and c:IsAbleToHand()
end
--values
function c88523888.atkval(e,c)
	return c:GetBaseAttack()/2
end
--equip limit
function c88523888.eqlimit(e,c)
	return c:IsSetCard(0x215a)
end
--Activate
function c88523888.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c88523888.eqfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c88523888.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,c88523888.eqfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end
function c88523888.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end
--atk boost condition
function c88523888.atkcon(e)
	local eq=e:GetHandler():GetEquipTarget()
	return eq and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function c88523888.atktg(e,c)
	return c==e:GetHandler():GetEquipTarget()
end
--deck destruction
function c88523888.deckcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c88523888.battle,1,nil,e:GetHandler():GetEquipTarget())
end
function c88523888.decktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,1)
end
function c88523888.deckop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardDeck(1-tp,1,REASON_EFFECT)
end
--effect destruction event
function c88523888.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41
end
function c88523888.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c88523888.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function c88523888.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c88523888.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end