--CodicecromaXY, Fusoliera Ergoriesumata
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	c:EnableReviveLimit()
	aux.AddFusionProcCode2(c,2003,2004,true,true)
	--atk gain
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--fusion success
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(aux.FusionSummonedCond)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--change damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	local ge1=Effect.CreateEffect(c)
	ge1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	ge1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	ge1:SetOperation(s.check)
	c:RegisterEffect(ge1)
	--ss
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetCost(aux.ToExtraSelfCost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
function s.check(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler()~=Duel.GetAttacker() then return end
	Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,re,r,rp,1-tp,0)
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.atkval(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local _,val=g:GetMaxGroup(Card.GetCode)
	val=val-math.fmod(val,50)
	return val
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac1=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT,ac1,OPCODE_ISCODE,OPCODE_NOT,OPCODE_AND}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac2=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	e:SetLabel(ac1,ac2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ac1,ac2=e:GetLabel()
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_DECK,nil,ac1,ac2)
	local dcount=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)
	if dcount==0 then return end
	if g:GetCount()==0 then
		Duel.ConfirmDecktop(1-tp,dcount)
		Duel.ShuffleDeck(1-tp)
		return
	end
	local seq=-1
	local tc=g:GetFirst()
	local rc=nil
	while tc do
		if tc:GetSequence()>seq then
			seq=tc:GetSequence()
			rc=tc
		end
		tc=g:GetNext()
	end
	Duel.ConfirmDecktop(1-tp,dcount-seq)
	if rc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and rc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then
		Duel.DisableShuffleCheck()
		Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,rc)
		Duel.DiscardDeck(1-tp,dcount-seq-1,REASON_EFFECT+REASON_REVEAL)
	elseif (rc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and rc:IsSSetable() then
		Duel.SSet(tp,rc)
	else
		Duel.ShuffleDeck(1-tp)
	end
end


function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local code=Duel.GetTargetParam()
	local eg0,eg1=global_duel_effect_table[0],global_duel_effect_table[1]
	if #eg0==0 and #eg1==0 then
		Duel.Win(tp,id)
		return
	end
	local check1,check2=false,false
	for _,ce in ipairs(eg0) do
		if ce and ce.GetLabel and ce:GetCode() and ce:GetCode()==EFFECT_NAME_DECLARED then
			local name=ce:GetValue()
			local turn=ce:GetLabel()
			if turn and ((Duel.GetTurnPlayer()==e:GetHandlerPlayer() and turn==(Duel.GetTurnCount()-2)) or (Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and turn==(Duel.GetTurnCount()-1))) then
				check1=true
				if code==name then
					check2=true
					break
				end
			end
		end
	end
	if not check then
		for _,ce in ipairs(eg1) do
			if ce and ce.GetLabel and ce:GetCode() and ce:GetCode()==EFFECT_NAME_DECLARED then
				local name=ce:GetValue()
				local turn=ce:GetLabel()
				if turn and ((Duel.GetTurnPlayer()==e:GetHandlerPlayer() and turn==(Duel.GetTurnCount()-2)) or (Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and turn==(Duel.GetTurnCount()-1))) then
					check1=true
					if code==name then
						check2=true
						break
					end
				end
			end
		end
	end
	if not check1 then
		Duel.Win(tp,id)
		return
	else
		if check2 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(4000)
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
			Duel.RegisterEffect(e1,tp)
		end
	end
end

function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	if sg:GetClassCount(Card.GetCode)>=2 then
		local ssg=aux.SelectUnselectGroup(sg,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
		if ssg and #ssg>0 then
			for tc in aux.Next(ssg) do
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_TURN_SELF,2)
				tc:RegisterEffect(e1)
			end
			Duel.SpecialSummonComplete()
		end
	end
end