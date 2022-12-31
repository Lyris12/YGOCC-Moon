--Selene, Assassina Silenziosa di Elyria
--Script by XGlitchy30
function c38648113.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,nil,2,nil,c38648113.lcheck)
	c:EnableReviveLimit()
	--protection
	--(this card)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c38648113.tgcon)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1x:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetCondition(c38648113.tgcon)
	e1x:SetValue(1)
	c:RegisterEffect(e1x)
	--(other monsters)
	local e1xx=Effect.CreateEffect(c)
	e1xx:SetType(EFFECT_TYPE_FIELD)
	e1xx:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET_TARGET)
	e1xx:SetRange(LOCATION_MZONE)
	e1xx:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1xx:SetCondition(c38648113.tgcon)
	e1xx:SetTarget(c38648113.tgtg)
	e1xx:SetValue(aux.imval1)
	c:RegisterEffect(e1xx)
	local e1xy=Effect.CreateEffect(c)
	e1xy:SetType(EFFECT_TYPE_FIELD)
	e1xy:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1xy:SetRange(LOCATION_MZONE)
	e1xy:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1xy:SetCondition(c38648113.tgcon)
	e1xy:SetTarget(c38648113.tgtg)
	e1xy:SetValue(1)
	c:RegisterEffect(e1xy)
	--
	local mcheck=Effect.CreateEffect(c)
	mcheck:SetType(EFFECT_TYPE_SINGLE)
	mcheck:SetCode(EFFECT_MATERIAL_CHECK)
	mcheck:SetValue(c38648113.valcheck)
	mcheck:SetLabelObject(e1)
	c:RegisterEffect(mcheck)
	local mclone=mcheck:Clone()
	mclone:SetLabelObject(e1x)
	c:RegisterEffect(mclone)
	local mclone2=mcheck:Clone()
	mclone2:SetLabelObject(e1xx)
	c:RegisterEffect(mclone2)
	local mclone3=mcheck:Clone()
	mclone3:SetLabelObject(e1xy)
	c:RegisterEffect(mclone3)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	--damage reduce
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2x:SetCondition(c38648113.rdcon)
	e2x:SetOperation(c38648113.rdop)
	c:RegisterEffect(e2x)
	--discard
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38648113,0))
	e3:SetCategory(CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCountLimit(1,38648113)
	e3:SetCondition(c38648113.dsccon)
	e3:SetTarget(c38648113.dsctg)
	e3:SetOperation(c38648113.dscop)
	c:RegisterEffect(e3)
end
--filters
function c38648113.lcheck(g,lc)
	return g:IsExists(Card.IsType,1,nil,TYPE_NORMAL)
end
--protection
function c38648113.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,38648101) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c38648113.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
function c38648113.tgtg(e,c)
	return c:IsType(TYPE_NORMAL) and e:GetHandler():GetLinkedGroup():IsContains(c)
end
--damage reduce
function c38648113.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c==Duel.GetAttacker() and Duel.GetAttackTarget()==nil
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function c38648113.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev/2)
end
--discard
function c38648113.dsccon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetAttackTarget()==nil
end
function c38648113.dsctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
end
function c38648113.dscop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0,nil)
	if g:GetCount()==0 then return end
	local sg=g:RandomSelect(1-tp,1)
	Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
end