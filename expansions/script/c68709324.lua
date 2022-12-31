--overdrive
--coded by Lyris. Card owned by Concordia.
function c68709324.initial_effect(c)
	--Activate: All "HDD" Monsters you control gain 1500 ATK. All battle damage your opponent takes this turn is halved. You can only activate 1 "CPU Gear: HDD Overdrive!" per turn.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,68709324+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c68709324.target)
	e1:SetOperation(c68709324.activate)
	c:RegisterEffect(e1)
end
function c68709324.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0xf09) end
end
function c68709324.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,nil,0xf09)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1500)
		tc:RegisterEffect(e1)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(0,1)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetValue(function (e,re,dam) return dam/2 end)
	Duel.RegisterEffect(e2,tp)
end
