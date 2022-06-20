--Groundhoard Territory
--Scripted by: XGlitchy30
local s,id=GetID()

function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--choose zone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.zntg)
	e2:SetOperation(s.znop)
	c:RegisterEffect(e2)
	--place
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--CHOOSE ZONE
function s.spfilter(c,e,tp,zone)
	return c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function s.ctfilter(c,tp,zone)
	return c:IsFaceup() and c:IsControlerCanBeChanged() and aux.IsZone(c,zone,tp)
end
function s.adjacent(p,e,tp,i)
	if p==tp then
		local zone,sx,dx=0,i-1,i+1
		if sx>=0 then zone=zone|(0x1<<sx) end
		if dx<=4 then zone=zone|(0x1<<dx) end
		return zone~=0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,zone)
	else
		i=i+16
		local zone,sx,dx=0,i-1,i+1
		if sx>=16 then zone=zone|(0x1<<sx) end
		if dx<=20 then zone=zone|(0x1<<dx) end
		return zone~=0 and Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,nil,tp,zone)
	end
end
function s.zntg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local check={false,false}
		local incr=(tp==0) and 1 or -1
		for p=tp,1-tp,incr do
			if check[p+1] then break end
			for i=0,4 do
				local index=(p==tp) and i or 4-i
				if not Duel.CheckLocation(p,LOCATION_MZONE,i) and not Duel.GetFieldGroup(p,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,p) and s.adjacent(p,e,tp,i) then
					check[p+1]=true
					break
				end
			end
		end
		return check[tp+1] or check[2-tp]
	end
	local zone=0
	local incr=(tp==0) and 1 or -1
	for p=tp,1-tp,incr do
		local x=(p==tp) and 0 or 16
		for i=0,4 do
			local index=(p==tp) and i or 4-i
			if not Duel.CheckLocation(p,LOCATION_MZONE,i) and not Duel.GetFieldGroup(p,LOCATION_MZONE,0):IsExists(s.zcheck,1,nil,i,p) and s.adjacent(p,e,tp,i) then
				zone=zone|(0x1<<(i+x))
			end
		end
	end
	local en=Duel.SelectField(tp,1,LOCATION_MZONE,LOCATION_MZONE,EXTRA_MONSTER_ZONE|(~zone),false)
	Duel.Hint(HINT_ZONE,tp,en)
	e:SetLabel(en)
	if math.log(en,2)<=4 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	else
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil,tp,zone)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
end
function s.zcheck(c,i,tp)
	local zone=0x1<<i
	return aux.IsZone(c,zone,tp)
end
function s.znop(e,tp,eg,ep,ev,re,r,rp)
	local en=e:GetLabel()
	if not en or en==0 or not e:GetHandler():IsRelateToChain(0) then return end
	local i=math.log(en,2)
	if i<=4 then
		local zone,sx,dx=0,i-1,i+1
		if sx>=0 then zone=zone|(0x1<<sx) end
		if dx<=4 then zone=zone|(0x1<<dx) end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,zone):GetFirst()
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)>0 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3000)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		local zone,sx,dx=0,i-1,i+1
		if sx>=16 then zone=zone|(0x1<<sx) end
		if dx<=20 then zone=zone|(0x1<<dx) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectMatchingCard(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil,tp,zone)
		local tc=g:GetFirst()
		if tc then
			Duel.GetControl(tc,tp,PHASE_END,1)
		end
	end
end


--PLACE
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsLocation(LOCATION_DECK) and rp~=tp and r&REASON_EFFECT>0
end
function s.filter(c)
	return (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup()) and c:IsRace(RACE_BEAST) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if #g>0 and not g:GetFirst():IsImmuneToEffect(e) and Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		local e1=Effect.CreateEffect(c)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		g:GetFirst():RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetCategory(CATEGORY_REMOVE)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetCountLimit(1)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCondition(s.rmcon)
		e2:SetTarget(s.rmtg)
		e2:SetOperation(s.rmop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		g:GetFirst():RegisterEffect(e2)
	end
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToChain(0) then return end
	local tc=Duel.GetFirstTarget()
	local seq=tc:GetSequence()
	if tc:IsControler(1-tp) then seq=seq+16 end
	if tc:IsRelateToChain(0) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE,1,fid)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		e1:SetCondition(s.rtcon)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DISABLE_FIELD)
		e2:SetLabel(seq)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.discon)
		e2:SetOperation(s.disop)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
	return tp==Duel.GetTurnPlayer()
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return
	end
	Duel.MoveToField(tc,PLAYER_NONE,tc:GetPreviousControler(),tc:GetPreviousLocation(),tc:GetPreviousPosition(),true)
	tc:SetReason(REASON_EFFECT+REASON_RETURN)
end
function s.discon(e,c)
	if e:GetLabelObject():IsLocation(LOCATION_REMOVED) then
		return true
	else
		e:Reset()
		return false
	end
end
function s.disop(e,tp)
	local dis1=(0x1<<e:GetLabel())
	return dis1
end