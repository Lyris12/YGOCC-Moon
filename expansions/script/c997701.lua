--Stellarius Arsenate
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--xyz summon
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x12D9),4,2,nil,nil,99)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(s.atlimit)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.xyzcon)
	e3:SetTarget(s.atktg)
	e3:SetValue(250)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	--Negate BP effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetTargetRange(0,1)
	e5:SetCode(EFFECT_CANNOT_ACTIVATE)
	e5:SetCondition(s.xyzcon2)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Disable Battle
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_BATTLED)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.xyzcon3)
	e6:SetOperation(s.disgy)
	c:RegisterEffect(e6)
	--Disable Effect
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetCondition(s.discon2)
	e7:SetOperation(s.disgy2)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_DISABLE)
	e8:SetRange(LOCATION_MZONE)
	e8:SetTargetRange(0,LOCATION_GRAVE)
	e8:SetTarget(s.distg2)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e9)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x12D9) and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_LINK)
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x12D9) and c:IsType(TYPE_FUSION+TYPE_XYZ+TYPE_LINK)
		and Duel.IsExistingMatchingCard(s.filter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,c)
end
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD) and c:IsSetCard(0x12D9)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	Duel.Hint(HINT_CARD,0,id)
end
function s.xyzcon(e)
	return e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetAttribute)>=1
end
function s.xyzcon2(e)
local ph=Duel.GetCurrentPhase()
	local tp=Duel.GetTurnPlayer()
	return tp==e:GetHandler():GetControler() and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
	and e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetAttribute)>=2
end
function s.atktg(e,c)
	return c:IsSetCard(0x12D9)
end
function s.xyzcon3(e)
	return e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetAttribute)>=3
end

function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	e:SetLabelObject(tc)
	return tc and (tc:GetReason()&0x40)==0x40 and re:GetOwner():IsType(TYPE_SPELL) and c:GetOverlayGroup():GetClassCount(Card.GetAttribute)>=4
end

function s.disgy2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetLabelObject(tc)
	c:RegisterFlagEffect(997701,RESET_EVENT+0x17a0000,0,1)
end
function s.distg2(e,c)
	return c:GetFlagEffect(997701)~=0
end

