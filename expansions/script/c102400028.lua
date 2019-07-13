--created & coded by Lyris, art at https://innocentmin.files.wordpress.com/2012/05/chinaprince.jpg
--S・VINEの王子ザフィル
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:IsActiveType(TYPE_MONSTER) or re:GetHandler():IsType(TYPE_MONSTER) end)
	e1:SetTarget(cid.destg)
	e1:SetOperation(cid.desop)
	c:RegisterEffect(e1)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(cid.discon)
	e4:SetTarget(cid.tg)
	e4:SetOperation(cid.op)
	c:RegisterEffect(e4)
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function cid.discon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler()
	return ec==Duel.GetAttackTarget() or ec==Duel.GetAttacker() and ec:GetBattleTarget()
end
function cid.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsControler(1-tp) and bc:IsControlerCanBeChanged() end
	Duel.SetTargetCard(bc)
end
function cid.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_WATER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_BATTLED)
		e3:SetOperation(cid.psop)
		e3:SetReset(RESET_PHASE+PHASE_END,1)
		Duel.RegisterEffect(e3,tp)
	end
end
function cid.psop(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetOwner():GetBattleTarget()
	if tg then
		Duel.GetControl(tg,tp,RESET_PHASE+PHASE_END,1)
	end
end
