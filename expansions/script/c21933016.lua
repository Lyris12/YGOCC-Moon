--Pendulum Pairvision
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
--ACTIVATE
function cid.tdfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:GetOriginalLevel()>0 and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(cid.pfilter,tp,LOCATION_DECK,0,1,nil,tp,c:GetOriginalLevel()-1)
end
function cid.pfilter(c,tp,lv)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_PENDULUM) and c:GetLeftScale()==c:GetRightScale() and c:GetLeftScale()==lv and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(cid.pfilter,tp,LOCATION_DECK,0,1,c,tp,lv+2)
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cid.tdfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,cid.tdfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	if #g>0 and Duel.SendtoDeck(g,nil,2,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		local lv=g:GetFirst():GetOriginalLevel()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g1=Duel.SelectMatchingCard(tp,cid.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp,lv-1)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,cid.pfilter,tp,LOCATION_DECK,0,1,1,g1:GetFirst(),tp,lv+1)
		g1:Merge(g2)
		if #g1<=0 then return end
		if Duel.SendtoHand(g1,nil,REASON_EFFECT)>0 then
			local hg=g1:Filter(Card.IsLocation,nil,LOCATION_HAND)
			local codes={}
			for hc in aux.Next(hg) do
				table.insert(codes,hc:GetCode())
			end
			Duel.ConfirmCards(1-tp,hg)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetLabel(table.unpack(codes))
			e1:SetTargetRange(1,0)
			e1:SetValue(cid.aclimit)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function cid.aclimit(e,re,tp)
	local code1,code2=e:GetLabel()
	return not re:GetHandler():IsCode(code1,code2) and re:IsActiveType(TYPE_PENDULUM) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end