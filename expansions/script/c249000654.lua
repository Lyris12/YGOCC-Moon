--Guardian-Summon Lethal Locomotive
function c249000654.initial_effect(c)
	c:SetUniqueOnField(1,0,249000654)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--atk/def
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c249000654.adcon)
	e2:SetOperation(c249000654.adop)
	c:RegisterEffect(e2)
	--actlimit
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(c249000654.aclimit)
	e3:SetCondition(c249000654.actcon)
	c:RegisterEffect(e3)
	--indes
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
	--pierce
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e6)
end
function c249000654.adcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:IsFaceup()
end
function c249000654.adop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() and not bc:IsImmuneToEffect(e) then
		local def=bc:GetDefense()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		bc:RegisterEffect(e1)
		if bc:IsFaceup() then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(def*-1)
			bc:RegisterEffect(e2)
		end			
	end
end
function c249000654.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_EFFECT)
end
function c249000654.actcon(e)
	return Duel.GetAttacker()==e:GetHandler()
end