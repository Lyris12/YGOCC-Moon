--Trumpeter
function c500317850.initial_effect(c)
	aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
	aux.AddEvoluteProc(c,nil,1,c500317850.filter2,1,1)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(500317850,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	--e1:SetCountLimit(1,500317850)
	e1:SetCondition(c500317850.con)
	e1:SetTarget(c500317850.tg)
	e1:SetOperation(c500317850.op)
	c:RegisterEffect(e1)
	--maintain
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c500317850.mtcon)
	e4:SetOperation(c500317850.mtop)
	c:RegisterEffect(e4)
end

function c500317850.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+388
end
function c500317850.filter2(c,ec,tp)
	return c:IsRace(RACE_FIEND) or c:IsAttribute(ATTRIBUTE_LIGHT)
end
function c500317850.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function c500317850.hspfilter(c,e,tp)
	return c:IsRace(RACE_FIEND) 
end
function c500317850.checkdiscard(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FIEND)
end
function c500317850.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local g=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,60,nil)
	if g:GetCount()>0 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		local op=Duel.GetOperatedGroup()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			local fcount=op:FilterCount(c500317850.checkdiscard,nil)
			if fcount>0 then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_BASE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(fcount*200)
				c:RegisterEffect(e1)
		   c:AddEC(fcount)
			end
		end
	end
end
function c500317850.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function c500317850.mtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsCanRemoveEC(tp,3,REASON_COST)  then
		Duel.RemoveEC(tp,3,REASON_COST)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end

