--Flibberty Dorpleflorp
local cid,id=GetID()
function cid.initial_effect(c)
	--flip
	local e0=Effect.CreateEffect(c)
	--e0:SetDescription(aux.Stringid(96381979,0))
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetTarget(cid.extg)
	e0:SetOperation(cid.exop)
	c:RegisterEffect(e0)
	--be target
	local e1=Effect.CreateEffect(c)
	--e1:SetDescription(aux.Stringid(62587693,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cid.condition)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.extg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
	Duel.SetTargetPlayer(tp)
end
function cid.thfilter(c,e,tp)
	return c:IsSetCard(0x5855) and ((c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()) or
		(c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function cid.exop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.ConfirmDecktop(p,5)
	local g=Duel.GetDecktopGroup(p,5)
	if g:GetCount()>0 and g:IsExists(cid.thfilter,1,nil,e,tp) and Duel.SelectYesNo(p,aux.Stringid(id,0)) then
		local sg=g:FilterSelect(p,cid.thfilter,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		if tc:IsType(TYPE_MONSTER) then
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			Duel.ConfirmCards(1-tp,tc)
		else
			Duel.SSet(tp,tc)
		end
	end
	Duel.ShuffleDeck(p)
end
function cid.filter(c)
	return c:IsSetCard(0x5855) and c:IsAbleToDeck()
end
function cid.filter2(c,tp)
	return c:IsSetCard(0x5855) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
		and c:IsControler(tp)
end
function cid.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()<1 then return false end
	local c=e:GetHandler()
	local tg=g:IsExists(cid.filter2,1,c,tp)
	return tg and c:IsFaceup() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cid.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.filter,tp,LOCATION_GRAVE,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,cid.filter,tp,LOCATION_GRAVE,0,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=3 then return end
	Duel.SendtoDeck(tg,nil,0,REASON_EFFECT)
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==3 then
		Duel.BreakEffect()
		local pos=Duel.SelectPosition(tp,c,POS_FACEDOWN_DEFENSE)
		Duel.ChangePosition(c,pos)
	end
end