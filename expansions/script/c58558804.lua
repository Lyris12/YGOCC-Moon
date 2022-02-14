--Flibberty Bibbityfroge
local cid,id=GetID()
function cid.initial_effect(c)
	--flip
	local e0=Effect.CreateEffect(c)
	--e0:SetDescription(aux.Stringid(96381979,0))
	e0:SetCategory(CATEGORY_POSITION)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e0:SetTarget(cid.postg)
	e0:SetOperation(cid.posop)
	c:RegisterEffect(e0)
	--be target
	local e1=Effect.CreateEffect(c)
	--e1:SetDescription(aux.Stringid(62587693,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.filter(c)
	return ((c:IsSetCard(0x5855) or c:IsSetCard(0x12)) and c:IsType(TYPE_MONSTER)) and not c:IsCode(id) and c:IsFaceup()
end
function cid.filter2(c)
	return c:IsFacedown() and c:IsDefensePos()
end
function cid.filter3(c)
	return c:IsFaceup() and not c:IsDisabled()
end
function cid.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_MZONE,0,1,nil) end
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function cid.posop(e,tp,eg,ep,ev,re,r,rp,chk)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local tc=Duel.GetFirstTarget()
	local pos=Duel.SelectPosition(tp,tc,POS_FACEDOWN_DEFENSE)
	if tc:IsRelateToEffect(e) and Duel.ChangePosition(tc,pos)~=0 then
		local g=Duel.SelectMatchingCard(tp,cid.filter2,tp,LOCATION_MZONE,0,1,1,nil)
		local tc2=g:GetFirst()
		if tc2 then
			local pos2=Duel.SelectPosition(tp,tc2,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
			Duel.ChangePosition(tc2,pos2)
		end
	end
end
function cid.filter4(c,tp)
	return c:IsSetCard(0x5855) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
		and c:IsControler(tp)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()<1 then return false end
	local c=e:GetHandler()
	local tg=g:IsExists(cid.filter4,1,c,tp)
	return tg and c:IsFaceup() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(cid.filter3,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,cid.filter3,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	local pos=Duel.SelectPosition(tp,c,POS_FACEDOWN_DEFENSE)
	if c:IsFaceup() and Duel.ChangePosition(c,pos)~=0 then
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e3)
	end
end