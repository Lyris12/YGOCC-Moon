--Ergoriesumante Siscodice
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	--e1:SetCost(aux.SPSummonRestr(true,s.counterfilter))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(aux.DiscardCost(nil,1))
	e2:SetSpellTrap(s.setf,LOCATION_DECK,0,1,1,false)
	c:RegisterEffect(e2)
	--material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:UsedAsMaterial(false,false,REASON_FUSION+REASON_LINK,s.matf)
	e3:SetCountLimit(1,id+200)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--activity check
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
s.expired_names={}
--FILTERS
function s.counterfilter(c)
	return c:IsSetCard(0xca4)
end
function s.setf(c)
	return c:IsCode(CARD_ANONYMIZE)
end
function s.matf(c)
	return c:IsRace(RACE_CYBERSE+RACE_FIEND)
end
--

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.SPSummonSelfTarget()(e,tp,eg,ep,ev,re,r,rp,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	if Duel.IsExistingMatchingCard(aux.AND(Card.IsCode,Card.IsFaceup),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,CARD_ANONYMIZE) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local newcode=Duel.GetTargetParam()
	local step=false
	if c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		step=true
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(newcode)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
		c:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
	if step and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_HAND,1,nil,e,0,1-tp,false,false) then
		Duel.BreakEffect()
		local res,g=aux.SPSummonStep(nil,0,LOCATION_HAND,1,1,1-tp)(e,tp,eg,ep,ev,re,r,rp)
		if res>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetValue(newcode)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
			g:GetFirst():RegisterEffect(e1)
			if e:GetLabel()==1 and aux.NegateAnyFilter(g:GetFirst()) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				g:GetFirst():RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				g:GetFirst():RegisterEffect(e2)
			end
		end
		Duel.SpecialSummonComplete()
	end
end

function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil,1-tp) end
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_AND,OPCODE_NOT}
	if #s.expired_names>0 then
		for _,name in ipairs(s.expired_names) do
			table.insert(getmetatable(e:GetHandler()).announce_filter,name)
			table.insert(getmetatable(e:GetHandler()).announce_filter,OPCODE_ISCODE)
			table.insert(getmetatable(e:GetHandler()).announce_filter,OPCODE_AND)
			table.insert(getmetatable(e:GetHandler()).announce_filter,OPCODE_NOT)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
	table.insert(s.expired_names,ac)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local code=Duel.GetTargetParam()
	return aux.BanishTemp(PHASE_END,1-tp,1,true,id,Card.IsCode,0,LOCATION_EXTRA,1,1,REASON_EFFECT,1-tp,nil,nil,nil,code)(e,tp,eg,ep,ev,re,r,rp)
end