--Paracyclis Stun Slammer, Thunderforce

local s,id=GetID()
function s.initial_effect(c)
	--deck check
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetLabel(0)
	e1:SetCost(aux.LabelCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DDD)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.srcon)
	e2:SetTarget(s.srtg)
	e2:SetOperation(s.srop)
	e2:SetCountLimit(1,id)
	c:RegisterEffect(e2)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsPlayerCanDiscardDeckAsCost(tp,1)
	end
	e:SetLabel(0)
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	local opinfo=false
	if tc:IsSetCard(0x308) then
		opinfo=true
	end
	if Duel.DiscardDeck(tp,1,REASON_COST)>0 and tc:IsLocation(LOCATION_GRAVE) and opinfo then
		Duel.SetTargetParam(1)
		local g=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,nil,tp)
		if #g>0 then
			Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,1-tp,LOCATION_MZONE)
		else
			Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
		end
	else
		Duel.SetTargetParam(0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ok=Duel.GetTargetParam()
	if ok~=1 then return end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,nil,tp)
	if #g>0 then
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		if not tc then return end
		Duel.HintSelection(sg)
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:Desc(2)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end

function s.srcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.filter(c)
	return c:IsSetCard(0x308) and c:GetLevel()>=8 and c:IsAbleToHand()
end
function s.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.srop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Search(g,tp)
	end
end
