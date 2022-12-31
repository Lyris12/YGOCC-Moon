--Dark Sapphire of Evil Vine
function c500312323.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
		--destroy
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(500312323,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c500312323.condition2)
	e4:SetTarget(c500312323.target2)
	e4:SetOperation(c500312323.operation2)
	c:RegisterEffect(e4)
--become material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c500312323.condition)
	e2:SetOperation(c500312323.operation)
	c:RegisterEffect(e2)
end
function c500312323.condition(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
function c500312323.operation(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:GetFlagEffect(500312323)==0 then
		--untargetable
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(500312323,0))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		rc:RegisterEffect(e1,true)
		rc:RegisterFlagEffect(500312323,RESET_EVENT+0x1fe0000,0,1)
			--untargetable
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetDescription(aux.Stringid(500312323,0))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+0x1fc0000)
		rc:RegisterEffect(e2,true)
		rc:RegisterFlagEffect(500312323,RESET_EVENT+0x1fe0000,0,1)
	end
end
function c500312323.condition2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function c500312323.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x485a)
end


function c500312323.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c500312323.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c500312323.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c500312323.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c500312323.operation2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		tc:RegisterEffect(e1)
	end
end