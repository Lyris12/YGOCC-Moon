--Flibberty Jiggler
local cid,id=GetID()
function cid.initial_effect(c)
	--flip
	local e0=Effect.CreateEffect(c)
	--e0:SetDescription(aux.Stringid(88316955,0))
	e0:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetTarget(cid.sptg)
	e0:SetOperation(cid.spop)
	c:RegisterEffect(e0)
	--be target
	local e1=Effect.CreateEffect(c)
	--e1:SetDescription(aux.Stringid(62587693,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.condition)
	e1:SetCost(cid.cost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.operation)
	c:RegisterEffect(e1)
end
function cid.filter1(c,e,tp)
	return c:IsSetCard(0x5855) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return false end
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return false end
		local g=Duel.GetMatchingGroup(cid.filter1,tp,LOCATION_DECK,0,nil,e,tp)
		return g:GetClassCount(Card.GetCode)>=1
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	local g=Duel.GetMatchingGroup(cid.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,1)
	if sg then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function cid.filter(c,tp)
	return c:IsControler(tp)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()<1 then return false end
	local c=e:GetHandler()
	local tg=g:IsExists(cid.filter,1,c,tp)
	return tg and c:IsFacedown() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.ChangePosition(e:GetHandler(),POS_FACEUP)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	local tc=Duel.GetOperatedGroup():GetFirst()
	Duel.ConfirmCards(1-tp,tc)
	if tc:IsSetCard(0x5855) then
		local st=Duel.SelectYesNo(tp,aux.Stringid(id,0))
		local res=false
		if st then
			if tc:IsType(TYPE_MONSTER) then
				res=Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				if res~=0 then Duel.ConfirmCards(1-tp,tc) end
			else
				res=Duel.SSet(tp,tc)
			end
		end
	else
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end