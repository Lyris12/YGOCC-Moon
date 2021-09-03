--Elohim, Messia Ængelico || Elohim, Ængelic Messiah
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--cannot remove
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BANISH)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(POS_FACEDOWN)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--choose
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetTarget(s.target)
	e3:SetOperation(s.activate)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsSetCard(0xae6)
end
--spsummon
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)>=3
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id-1,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not s.counterfilter(c)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
--choose
function s.rmfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)>=3
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_REMOVED,0,nil)
	if #g>=3 then
		local cg=Group.CreateGroup()
		for i=1,3 do
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
			local sg=g:Select(tp,1,1,cg)
			cg:Merge(sg)
		end
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
		local tg=cg:Select(1-tp,1,1,nil)
		local tc=tg:GetFirst()
		Duel.Hint(HINT_CARD,1-tp,tc:GetCode())
		if tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,nil,tp,POS_FACEDOWN) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_MZONE,0,1,tc,tp,POS_FACEDOWN) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
				local rg=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_MZONE,0,1,1,tc,tp,POS_FACEDOWN)
				if #rg>0 then
					Duel.BreakEffect()
					Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)
				end
			end
		end
	end
end