--Groundhoard Burrown
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--summon proc
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_SPSUMMON_PROC_G)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.nscon)
	e2:SetOperation(s.nsop)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(s.mattg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--grant effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
--SUMMON PROC
function s.nscon(e,c)
	if c==nil then return true end
	return c:IsSummonable(false,nil) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Summon(tp,c,false,nil)
	if c:IsLocation(LOCATION_MZONE) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
		e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
		e1:SetCondition(s.xtrcon(Duel.GetCurrentPhase()))
		e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST))
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
	return false
end
function s.xtrcon(ph)
	return	function(e)
				return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and Duel.GetCurrentPhase()==ph
			end
end
function s.mattg(e,c)
	return c:GetType()&0x20004==0x20004 and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:GetOriginalRace()&RACE_BEAST==RACE_BEAST
end

--GRANT EFFECT
function s.filter(c)
	return c:IsFaceup() and s.mattg(nil,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.efilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_SZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c,tc=e:GetHandler(),Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsFaceup() or not tc:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.zntg)
	e1:SetOperation(s.znop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
function s.zntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)<=0 or Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_COUNT)<=0 then return false end
		local check=false
		for i=0,4 do
			if Duel.CheckLocation(tp,LOCATION_MZONE,i) and Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i) then
				check=true
				break
			end
		end
		return check
	end
	local zone=0
	for i=0,4 do
		if Duel.CheckLocation(tp,LOCATION_MZONE,i) and Duel.CheckLocation(1-tp,LOCATION_MZONE,4-i) then
			zone=zone|(0x1<<i)
		end
	end
	local dis1=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,EXTRA_MONSTER_ZONE|(~zone),false)
	local czone=0x1<<(math.log(dis1,2)*-1+20)
	local dis2=Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,EXTRA_MONSTER_ZONE|(~czone),false)
	Duel.Hint(HINT_ZONE,tp,dis1|dis2)
	e:SetLabel(dis1|dis2)
end
function s.znop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE_FIELD)
	e1:SetLabel(e:GetLabel())
	e1:SetOperation(s.disop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.disop(e,tp)
	return e:GetLabel()
end