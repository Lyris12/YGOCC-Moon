--Sieger Ennigmatrix
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,2,cid.ovfilter,aux.Stringid(id,0),3,cid.xyzop)
	c:EnableReviveLimit()
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.atkcon)
	e1:SetValue(1500)
	c:RegisterEffect(e1)
	--attach
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetCountLimit(1)
	e2:SetTarget(cid.athtg)
	e2:SetOperation(cid.athop)
	c:RegisterEffect(e2)
end
--filters
function cid.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xead) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_XYZ)
end
function cid.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
--atkup
function cid.atkcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and e:GetHandler():GetOverlayCount()>=5
end
--attach
function cid.athtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
function cid.athop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<=1 or not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	local td=Duel.GetDecktopGroup(tp,2)
	Duel.Overlay(e:GetHandler(),td)
end