--HDD Nepgear
--Coded by Concordia
function c68709341.initial_effect(c)
	--link summon
    aux.AddLinkProcedure(c,c68709341.lfilter,2)
    c:EnableReviveLimit()
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c68709341.atkval)
	c:RegisterEffect(e1)
	--inactivatable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_INACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetValue(c68709341.effectfilter)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_DISEFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(c68709341.effectfilter)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c68709341.btag)
	e4:SetOperation(c68709341.bop)
	c:RegisterEffect(e4)	
end
function c68709341.lfilter(c)
    return c:IsType(TYPE_MONSTER) and (c:IsSetCard(0xf08) or c:IsSetCard(0xf09))
end
function c68709341.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf08) or c:IsSetCard(0xf09)
end
function c68709341.atkval(e,c)
	return c:GetLinkedGroupCount(c68709341.atkfilter)*200
end
function c68709341.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp,loc=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_LOCATION)
	return p==tp and te:GetHandler():IsSetCard(0xf08) and te:GetHandler():IsSetCard(0xf09) and bit.band(loc,LOCATION_ONFIELD)~=0
end
function c68709341.cfilter(c,tp)
    return c:IsLevelAbove(0) and c:IsSetCard(0xf08) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
function c68709341.btag(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return (chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c68709341.desfilter1(chkc)) end
    if chk==0 then return Duel.IsExistingTarget(c68709341.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectTarget(tp,c68709341.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function c68709341.bop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local fc=g:GetFirst()
		while fc do
    		local e1=Effect.CreateEffect(e:GetHandler())
    		e1:SetType(EFFECT_TYPE_SINGLE)
    		e1:SetCode(EFFECT_UPDATE_ATTACK)
    		e1:SetValue(tc:GetLevel()*200)
    		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
    		fc:RegisterEffect(e1)
    		fc=g:GetNext()
		end
	end
end