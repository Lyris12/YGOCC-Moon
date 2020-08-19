--created & coded by Lyris
--インライトメント・エアトス翼
local cid,id=GetID()
function cid.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCondition(cid.atkcon)
	e1:SetTarget(cid.atktg2)
	e1:SetOperation(cid.atkop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(cid.natkcon)
	c:RegisterEffect(e2)
	Duel.AddCustomActivityCounter(id,ACTIVITY_ATTACK,cid.diratk(c))
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetCondition(cid.descon)
	e3:SetTarget(cid.destg)
	e3:SetOperation(cid.desop)
	c:RegisterEffect(e3)
end
function cid.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return a:IsControler(tp) and a:IsSetCard(0xda6) and at
end
function cid.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.GetAttacker():IsHasEffect(EFFECT_CANNOT_DIRECT_ATTACK) end
end
function cid.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeAttackTarget(nil)
end
function cid.natkcon(e)
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_ATTACK)>0
end
function cid.diratk(ec)
	return  function(c)
				return Duel.GetAttackTarget()~=nil or c==ec
			end
end
function cid.descon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if d and d:IsControler(tp) then a,d=d,a end
	return a:IsSetCard(0xda6) and a~=e:GetHandler()
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local dir=Duel.GetAttackTarget()==nil
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	if Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
		if dir then
			e:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
			Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetAttack()/2)
		end
	end
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local dir=Duel.GetAttackTarget()==nil
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local atk=tc:GetAttack()
		if atk<0 or tc:IsFacedown() then atk=0 end
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and dir then
			Duel.Damage(1-tp,atk/2,REASON_EFFECT)
		end
	end
end
