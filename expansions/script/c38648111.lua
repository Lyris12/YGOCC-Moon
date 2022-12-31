--Kurvik, Grande Difensore di Elyria
function c38648111.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_NORMAL),2,2)
	c:EnableReviveLimit()
	--protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c38648111.tgcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetType(EFFECT_TYPE_SINGLE)
	e1x:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1x:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1x:SetRange(LOCATION_MZONE)
	e1x:SetCondition(c38648111.tgcon)
	e1x:SetValue(1)
	c:RegisterEffect(e1x)
	local mcheck=Effect.CreateEffect(c)
	mcheck:SetType(EFFECT_TYPE_SINGLE)
	mcheck:SetCode(EFFECT_MATERIAL_CHECK)
	mcheck:SetValue(c38648111.valcheck)
	mcheck:SetLabelObject(e1)
	c:RegisterEffect(mcheck)
	local mclone=mcheck:Clone()
	mclone:SetLabelObject(e1x)
	c:RegisterEffect(mclone)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38648111,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,38648111)
	e2:SetCondition(c38648111.drycon)
	e2:SetTarget(c38648111.drytg)
	e2:SetOperation(c38648111.dryop)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetDescription(aux.Stringid(38648111,0))
	e2x:SetCategory(CATEGORY_DESTROY)
	e2x:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2x:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET)
	e2x:SetCode(EVENT_TO_DECK)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetCountLimit(1,38648111)
	e2x:SetCondition(c38648111.drycon2)
	e2x:SetTarget(c38648111.drytg)
	e2x:SetOperation(c38648111.dryop)
	c:RegisterEffect(e2x)
end
--filters
function c38648111.cfilter(c,tp)
	return c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_NORMAL) and c:IsType(TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_MZONE)
end
--protection
function c38648111.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsCode,1,nil,38648103) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function c38648111.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK) and e:GetLabel()==1
end
--destroy
function c38648111.drycon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function c38648111.drycon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c38648111.cfilter,1,nil,tp)
end
function c38648111.drytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function c38648111.dryop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then 
		Duel.Destroy(tc,REASON_EFFECT)
	end
end