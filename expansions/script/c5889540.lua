--Parapsiche Marmotta
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--special summon proc
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--place as trap
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCustomCategory(CATEGORY_PLACE_AS_CONTINUOUS_TRAP,CATEGORY_FLAG_SELF)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series = {0xa4a}

--special summon proc
function s.spfilter(c,tp)
	return (c:IsFaceup() or not c:IsOnField()) and ((c:IsMonster() and c:IsRace(RACE_BEAST)) or c:IsOnField() and c:GetType()&TYPE_TRAP+TYPE_CONTINUOUS==TYPE_TRAP+TYPE_CONTINUOUS) and not c:IsCode(id)
		and c:IsAbleToHandAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,c)
	if c:IsLocation(LOCATION_GRAVE) then
		local eff={c:IsHasEffect(EFFECT_NECRO_VALLEY)}
		for _,te in ipairs(eff) do
			local op=te:GetOperation()
			if not op or op(e,c) then return false end
		end
	end
	local tp=c:GetControler()
	return aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,c)
	local g=aux.SelectUnselectGroup(rg,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RTOHAND,nil,nil,true)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoHand(g,nil,REASON_COST)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+0x047e0000)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1,true)
	g:DeleteGroup()
end

--place as trap
function s.filter(c)
	return (c:IsFaceup() or not c:IsOnField()) and c:IsMonster() and (c:IsRace(RACE_BEAST) or c:IsSetCard(0xa4a))
end
function s.spf(c,e,tp,tc)
	return c:IsMonster() and c:IsRace(RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not tc or Duel.IsExistingMatchingCard(s.cnf,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,tc,{c:GetCode()}))
end
function s.cnf(c,codes)
	return c:IsFaceup() and c:GetType()&TYPE_TRAP+TYPE_CONTINUOUS==TYPE_TRAP+TYPE_CONTINUOUS and c:IsCode(table.unpack(codes))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_DECK,0,1,nil,e,tp)
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>0
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) and (b1 or b2)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_PLACE_AS_CONTINUOUS_TRAP,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		if not g:GetFirst():IsImmuneToEffect(e) and Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
			g:GetFirst():RegisterEffect(e1)
			--
			local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spf,tp,LOCATION_DECK,0,1,nil,e,tp,g:GetFirst())
			local b2=Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)+Duel.GetLocationCount(1-tp,LOCATION_MZONE,PLAYER_NONE,0)>0
			local off=1
			local ops={}
			local opval={}
			if b1 then
				ops[off]=aux.Stringid(id,2)
				opval[off]=0
				off=off+1
			end
			if b2 then
				ops[off]=aux.Stringid(id,3)
				opval[off]=1
				off=off+1
			end
			local op=Duel.SelectOption(tp,table.unpack(ops))+1
			local sel=opval[op]
			e:SetLabel(sel)
			Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,sel+2))
			if sel==0 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,s.spf,tp,LOCATION_DECK,0,1,1,nil,e,tp,g:GetFirst())
				if #sg>0 then
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			elseif sel==1 then
				local zone=Duel.SelectDisableField(tp,1,LOCATION_MZONE,LOCATION_MZONE,EXTRA_MONSTER_ZONE)
				Duel.Hint(HINT_ZONE,tp,zone)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_DISABLE_FIELD)
				e1:SetRange(LOCATION_SZONE)
				e1:SetLabel(zone)
				e1:SetOperation(s.disop)
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.disop(e,tp)
	return e:GetLabel()
end