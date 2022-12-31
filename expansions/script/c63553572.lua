--Prima Markshall
--Scripted by: XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(cid.tkcost)
	e1:SetTarget(cid.tktg)
	e1:SetOperation(cid.tkop)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(cid.sptg)
	e2:SetOperation(cid.spop)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2x)
	--material effect
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(cid.matcon)
	e3:SetOperation(cid.matop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,cid.counterfilter)
end
function cid.counterfilter(c)
	return c:IsSetCard(0x7a4) or c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM)
end

--TOKEN
function cid.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cid.splimit)
	Duel.RegisterEffect(e1,tp)
end
function cid.splimit(e,c)
	return not cid.counterfilter(c)
end
function cid.filter0(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and c:IsRace(RACE_MACHINE)
		and Duel.IsExistingMatchingCard(cid.dryfilter,tp,LOCATION_DECK,0,1,nil,e,c:GetOriginalAttribute())
end
function cid.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and cid.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter0,tp,LOCATION_MZONE,0,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,63553586,0x7a4,0x4011,1000,1000,4,RACE_MACHINE,ATTRIBUTE_LIGHT)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cid.filter0,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function cid.dryfilter(c,e,attr)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and (not e or c:IsDestructable(e))
		and (not attr or c:GetOriginalAttribute()~=attr) and (c:IsLocation(LOCATION_DECK) and c:IsSetCard(0x7a4) or c:IsFaceup())
end
function cid.tkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,cid.dryfilter,tp,LOCATION_DECK,0,1,1,nil,e,tc:GetOriginalAttribute())
	if #g>0 and Duel.Destroy(g:GetFirst(),REASON_EFFECT)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,63553586,0x7a4,0x4011,1000,1000,4,RACE_MACHINE,ATTRIBUTE_LIGHT) then
			return
		end
		local token=Duel.CreateToken(tp,63553586)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end

--SPSUMMON
function cid.filter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x7a4) and c:IsType(TYPE_PENDULUM+TYPE_PANDEMONIUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (not c:IsLocation(LOCATION_REMOVED) or c:IsFaceup())
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and cid.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,aux.NecroValleyFilter(cid.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function cid.pfilter(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
		and (c:IsType(TYPE_PENDULUM) and (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			or (c:IsType(TYPE_PANDEMONIUM) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandActCon(nil,c)(e,tp,eg,ep,ev,re,r,rp)))
end	
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local b1=Duel.IsExistingMatchingCard(cid.dryfilter,tp,LOCATION_MZONE,0,1,nil)
		local b2=Duel.IsExistingMatchingCard(cid.pfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
		local b={b1,b2}
		if not b[1] and not b[2] then return end
		local off=1
		local ops={}
		local opval={}
		for i=1,2 do
			if b[i] then
				ops[off]=aux.Stringid(id,i+1)
				opval[off]=i-1
				off=off+1
			end
		end
		local op=Duel.SelectOption(tp,table.unpack(ops))+1
		local sel=opval[op]
		if sel==0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local g=Duel.SelectMatchingCard(tp,cid.dryfilter,tp,LOCATION_MZONE,0,1,1,nil,nil,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.Destroy(g:GetFirst(),REASON_EFFECT)
			end
		elseif sel==1 then
			local g=Duel.SelectMatchingCard(tp,cid.pfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
			if #g>0 then
				if g:GetFirst():IsType(TYPE_PENDULUM) then
					Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
				else
					aux.PandAct(g:GetFirst(),tp,0xff,true)(e,tp,eg,ep,ev,re,r,rp)
				end
			end
		end
	end
end

--MATERIAL EFFECT
function cid.matcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EXTRA)~=0
end
function cid.matop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	--act limit
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(cid.chainop)
	rc:RegisterEffect(e3)
end
function cid.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler()==e:GetHandler() then
		Duel.SetChainLimit(cid.chainlm)
	end
end
function cid.chainlm(e,rp,tp)
	return tp==rp
end