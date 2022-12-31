--Vasiariah, Radiosità Ængelica || Vasiariah, Ængelic Radiance
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,11,s.TLcon,aux.FilterBoolFunction(Card.IsSetCard,0xae6),s.TLop)
	--ss
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Destroy 1 monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
--timeleap summon
function s.TLcon(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_REMOVED,0,nil)>=7
end
function s.TLop(e,tp,eg,ep,ev,re,r,rp,c,g)
	Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL+REASON_TIMELEAP)
	aux.TimeleapHOPT(tp)
end
--ss
function s.condition(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_TIMELEAP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)>=5
	end
	local ag=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_MZONE,0,e:GetHandler())
	local atk=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)*100
	if #ag>0 and atk>0 then
		Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,ag,#ag,tp,atk)
	end
end
function s.cffilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xae6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.afilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xae6) and c:IsFaceup()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
	if #g>=5 then
		local cg=Group.CreateGroup()
		for i=1,5 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
			local sg=g:Select(tp,1,1,cg)
			cg:Merge(sg)
		end
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
		local tg=cg:Select(1-tp,2,2,nil)
		Duel.ConfirmCards(1-tp,tg)
		for tc in aux.Next(tg) do
			Duel.Hint(HINT_CARD,1-tp,tc:GetCode())
		end
		local sg=tg:Filter(s.cffilter,nil,e,0,tp,false,false)
		local fg=Group.CreateGroup()
		fg:KeepAlive()
		if #sg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			local ct=(Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) and 1 or math.min(#sg,Duel.GetLocationCount(tp,LOCATION_MZONE))
			if ct~=2 then
				for i=1,ct do
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local sc=sg:Select(tp,1,1,nil)
					if #sc>0 then
						fg:Merge(sc)
					end
				end
			else
				fg:Merge(sg)
			end
			if #fg>0 then
				Duel.SpecialSummon(fg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
		local ag=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_MZONE,0,e:GetHandler())
		local atk=Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)*100
		if #ag>0 and atk>0 then
			Duel.BreakEffect()
			for tc in aux.Next(ag) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				e1:SetValue(atk)
				tc:RegisterEffect(e1)
			end
		end
	end
end
--destroy
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil,POS_FACEDOWN) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil,POS_FACEDOWN)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end