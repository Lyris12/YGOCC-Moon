--Reactor A.W. - The Zone
function c213170.initial_effect(c)
	c:EnableCounterPermit(0xf)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk, def down
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c213170.aatkcon)
	e2:SetValue(c213170.aatkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--counter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetCondition(c213170.actcon)
	e4:SetOperation(c213170.actop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	--add counter
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHANGE_POS)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c213170.wccon)
	e6:SetOperation(c213170.wcop)
	c:RegisterEffect(e6)
	--atk, def up
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_UPDATE_ATTACK)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(LOCATION_MZONE,0)
	e7:SetTarget(aux.TargetBoolFunction(c213170.watkfilter))
	e7:SetValue(c213170.watkval)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e8)
	--position
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(213170,0))
	e9:SetCategory(CATEGORY_HANDES+CATEGORY_POSITION)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_SZONE)
	e9:SetCountLimit(1,213170)
	e9:SetTarget(c213170.postg)
	e9:SetOperation(c213170.posop)
	c:RegisterEffect(e9)
end
function c213170.aatkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc)
end
function c213170.aatkcon(e)
	return Duel.IsExistingMatchingCard(c213170.aatkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function c213170.aatkval(e,c)
	return c:GetCounter(0x100e)*-300
end
c213170.counter_add_list={0x100e}
function c213170.acfilter(c,tp)
	return c:GetSummonPlayer()==tp
end
function c213170.actcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c213170.acfilter,1,nil,1-tp)
end
function c213170.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,213170)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x100e,1)
		tc=g:GetNext()
	end
end
function c213170.wcfilter(c)
	return bit.band(c:GetPreviousPosition(),POS_FACEDOWN)~=0 and bit.band(c:GetPosition(),POS_FACEUP)~=0
end
function c213170.wccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c213170.wcfilter,1,e:GetHandler())
end
function c213170.wcop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xf,1)
end
function c213170.watkfilter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE)
end
function c213170.watkval(e,c)
	return e:GetHandler():GetCounter(0xf)*300
end
function c213170.filter(c)
	return c:IsRace(RACE_REPTILE) and c:IsDiscardable(REASON_EFFECT)
end
function c213170.posfilter(c)
	return (c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsCanChangePosition())
		or (c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanTurnSet())
end
function c213170.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c213170.filter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(c213170.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,LOCATION_HAND)
end
function c213170.posop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,c213170.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)~=0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local pg=Duel.SelectMatchingCard(tp,c213170.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if pg:GetCount()>0 then
			Duel.HintSelection(pg)
			local pc=pg:GetFirst()
			if pc:IsFacedown() then
				Duel.ChangePosition(pc,POS_FACEUP_ATTACK)
			else
				Duel.ChangePosition(pc,POS_FACEDOWN_DEFENSE)
			end
		end
	end
end