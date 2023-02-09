--Zextral Armageddon Sorcerer
local cid,id=GetID()
function cid.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	--P: Once per turn, when your opponent activates a card or effect that targets and/or would destroy a Pandemonium Monster(s) you control: You can shuffle 1 face-up Pandemonium Monster from your Extra Deck into the Deck; negate that card or effect, and destroy it.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(aux.PandActCheck)
	e2:SetCost(cid.discost)
	e2:SetTarget(cid.distg)
	e2:SetOperation(cid.disop)
	c:RegisterEffect(e2)
	aux.EnablePandemoniumAttribute(c,e2)
	--P: You can only Pandemonium Summon "Zextra, The Pandemonium Dragon King". This effect cannot be negated.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,0)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetTarget(cid.splimit)
	c:RegisterEffect(e1)
	--M: If a card(s) you control is destroyed by battle or card effect: You can Special Summon this card from your hand, then you can Set 1 Pandemonium Monster directly from your Extra Deck in your Spell/Trap Zone. (HOPT1)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,id)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCondition(cid.spcon)
	e3:SetTarget(cid.sptg)
	e3:SetOperation(cid.spop)
	c:RegisterEffect(e3)
	--M: You can banish this card you control, plus 4 Pandemonium Monsters from your hand, field, and/or GY with different names; Special Summon 1 "Zextra, The Pandemonium Dragon King" from your hand, Deck, or face-up in your Extra Deck. (HOPT2)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+100)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCost(cid.cost)
	e4:SetTarget(cid.target)
	e4:SetOperation(cid.operation)
	c:RegisterEffect(e4)
end
function cid.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:GetCode()==39605510 then return false end
	return aux.PandActCheck(e) and bit.band(sumtype,SUMMON_TYPE_SPECIAL+726)==SUMMON_TYPE_SPECIAL+726
end
function cid.confilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM)
end
function cid.dcfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PANDEMONIUM) and c:IsAbleToDeckAsCost()
end
function cid.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.dcfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.dcfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,2,REASON_COST)
	end
end
function cid.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if not re then
		ev=Duel.GetCurrentChain()-1
		re=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
		eg=re:GetHandler()
	end
	if chk==0 then
		if re:GetHandler():IsStatus(STATUS_DISABLED) or not Duel.IsChainNegatable(ev) then return false end
		if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
			local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
			if tg and tg:IsExists(cid.confilter,1,nil,tp) then return true end
		end
		if re:IsHasCategory(CATEGORY_NEGATE) and ev>1
			and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
		local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
		return ex and tg~=nil and tc+tg:FilterCount(cid.confilter,nil,tp)-tg:GetCount()>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if not re then
		ev=math.max(Duel.GetCurrentChain()-1,1)
		re=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_EFFECT)
		eg=re:GetHandler()
	end
	if not re:GetHandler():IsStatus(STATUS_DISABLED) and Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function cid.spcfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousControler()==tp
end
function cid.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(cid.spcfilter,1,nil,tp)
end
function cid.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function cid.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local g=Duel.GetMatchingGroup(aux.AND(aux.FilterBoolFunction(Card.IsFaceup),aux.FilterBoolFunction(Card.IsType,TYPE_PANDEMONIUM)),tp,LOCATION_EXTRA,0,nil)
		if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandSSetCon(cid.setfilter,nil,LOCATION_EXTRA)(nil,e,tp,eg,ep,ev,re,r,rp) and Duel.SelectYesNo(tp,1159) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
			local sg=g:FilterSelect(tp,aux.PandSSetFilter(aux.TRUE),1,1,nil,e,tp,eg,ep,ev,re,r,rp)
			aux.PandSSet(sg,REASON_EFFECT,aux.GetOriginalPandemoniumType(sg:GetFirst()))(e,tp,eg,ep,ev,re,r,rp)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function cid.setfilter(c)
	return c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
function cid.cfilter(c)
	return c:IsType(TYPE_PANDEMONIUM) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function cid.hnfilter(c,e,tp,g)
	local sg=Group.CreateGroup()
	return c:IsCode(39605510) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()) 
		and (not g or g:IsExists(cid.check,1,c,tp,g,c,sg,0))
end
function cid.hnfilter_zone(c,e,tp)
	return c:IsCode(39605510) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and ((c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp)>0)
	or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
end
function cid.check(c,tp,mg,sc,sg,ct)
	sg:AddCard(c)
	local fixsg=sg:Clone()
	fixsg:AddCard(sc)
	ct=ct+1
	local res=cid.goal(tp,sg,sc,ct)
		or (ct<4 and mg:IsExists(cid.check,1,fixsg,tp,mg,sc,sg,ct))
	sg:RemoveCard(c)
	ct=ct-1
	return res
end
function cid.goal(tp,sg,sc,ct)
	return ct>=4 and sg:GetClassCount(Card.GetCode)>=4 and ((sc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg)>0) 
		or (1+Duel.GetLocationCount(tp,LOCATION_MZONE))>-sg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE))
end
function cid.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=Duel.GetMatchingGroup(cid.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,c)
	mg:KeepAlive()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(cid.hnfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp,mg) 
	end
	local sc=Duel.SelectMatchingCard(tp,cid.hnfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp,mg):GetFirst()
	local sg=Group.FromCards(c)
	local fixsg=Group.FromCards(c,sc)
	local ct=0
	while sg:GetCount()<5 do
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=mg:FilterSelect(tp,cid.check,1,1,fixsg,tp,mg,sc,sg,ct)
		local code=g:GetFirst():GetCode()
		sg:Merge(g)
		fixsg:Merge(g)
		mg:Remove(Card.IsCode,nil,code)
		ct=ct+1
	end
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA)
end
function cid.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,cid.hnfilter_zone,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
