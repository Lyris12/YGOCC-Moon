--Mezodrives Huntress
local cid,id=GetID()
function cid.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigXrosType(c)
	aux.AddXrosProc(c,nil,4,aux.TRUE,1,3)
	--Once per turn: You can target 1 face-up monster on the field; it lose ATK equal to the difference of ATK between this card and that target.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetCondition(aux.XrosEffectCon())
	e1:SetTarget(cid.atktg)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)
	--If this card would be destroyed by battle or card effect, you can Unload 1 Core from this card instead.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(aux.XrosEffectCon())
	e2:SetTarget(cid.reptg)
	e2:SetOperation(cid.repop)
	c:RegisterEffect(e2)
	--Gate: [1 monster] If this card destroys a monster by battle: You can Tribute this card; gain 1 Reserve for each cards in your hand.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(cid.grcon)
	e3:SetCost(cid.cost)
	e3:SetOperation(cid.grop)
	c:RegisterEffect(e3)
end
function cid.filter(c,tc)
	return c:IsFaceup() and c:GetAttack()~=tc:GetAttack()
end
function cid.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and cid.filter(chkc,c) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,c)
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e)) or c:GetAttack()==tc:GetAttack() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(-math.abs(c:GetAttack()-tc:GetAttack()))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
function cid.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and c:IsReason(REASON_BATTLE+REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function cid.repop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
function cid.grcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return aux.XrosEffectCon(Card.IsType,TYPE_EFFECT)(e) and c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	Duel.Release(c,REASON_COST)
end
function cid.grop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeReserve(tp,Duel.GetFieldGroupCount(tp,LOCATION_HAND,0))
end
