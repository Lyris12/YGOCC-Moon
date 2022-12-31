--Chronologist Engineer
--Keddy was here~
local function ID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
xpcall(function() require("expansions/script/c39507090") end,function() require("script/c39507090") end)

local id,cod=ID()
function cod.initial_effect(c)
	--Search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(cod.thcon)
	e1:SetTarget(cod.thtg)
	e1:SetOperation(cod.thop)
	c:RegisterEffect(e1)
	--Deactivate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39507090,10))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetTarget(cod.dtg)
	e2:SetOperation(cod.dop)
	c:RegisterEffect(e2)
	--Activate
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39507090,11))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id)
	e3:SetTarget(cod.atg)
	e3:SetOperation(cod.aop)
	c:RegisterEffect(e3)
end

--Is Linked
function cod.lfilter(c,ec)
	local g=c:GetLinkedGroup()
	if #g==0 then return end
	return c:IsSetCard(0x593) and g:IsContains(ec)
end
function cod.gfilter(c)
	return c:IsType(TYPE_LINK) and c:GetLinkMarker()~=0
end
function cod.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id)==0 then return true end
	local ct=Duel.GetFlagEffect(tp,id)
	local g=Duel.GetMatchingGroup(cod.gfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if ct==1 then
		return g:IsExists(cod.lfilter,1,nil,c) or c:IsHasEffect(39507190)
	else
		return false
	end
end
function cod.thfilter(c)
	return c:IsSetCard(0x593) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function cod.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
function cod.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,cod.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--Deactivate
function cod.dfilter(c)
	return c:IsType(TYPE_LINK) and c:GetLinkMarker()~=0
end
function cod.dtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and cod.dfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cod.dfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cod.dfilter,tp,LOCATION_ONFIELD,0,1,2,nil)
end
function cod.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	while tc do
		if not tc:IsRelateToEffect(e) then return end
		local lk,ops=Card.LinkCheck(tc)
		Duel.HintSelection(Group.FromCards(tc))
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,8))
		local op=Duel.SelectOption(tp,table.unpack(ops))
		link=tc:GetLinkMarker()-lk[op]
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
		e1:SetValue(link)
		e1:SetReset(RESET_EVENT+0x01fe0000)
		tc:RegisterEffect(e1,true)
		Duel.RaiseEvent(tc,EVENT_CUSTOM+39507090+tc:GetCode(),e,0,tp,tp,link)
		tc=g:GetNext()
	end
end

--D&A
function cod.afilter1(c,tp)
	return c:GetLinkMarker()~=0 and c:IsType(TYPE_LINK)
		and Duel.IsExistingMatchingCard(cod.afilter2,tp,LOCATION_ONFIELD,0,1,c)
end
function cod.afilter2(c)
   return c:GetLinkMarker()~=0 and c:IsType(TYPE_LINK)
end
function cod.atg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and cod.afilter1(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(cod.afilter1,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,12))
	local g1=Duel.SelectTarget(tp,cod.afilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,13))
	local g2=Duel.SelectTarget(tp,cod.afilter2,tp,LOCATION_ONFIELD,0,1,1,g1:GetFirst())
end
function cod.aop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:GetCount()<=0 then return end
	local tc=e:GetLabelObject()
	local g1=g:GetFirst()
	if g1==tc then
		ac=g:GetNext()
	else ac=g:GetFirst() end
	if not tc:IsRelateToEffect(e) 
		or not g:IsExists(function(c,tc) return c==tc end,1,nil,tc) then return end
	local lk,ops=Card.LinkCheck(tc)
	--First Card
	Duel.HintSelection(Group.FromCards(tc))
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,8))
	local op=Duel.SelectOption(tp,table.unpack(ops))
	link=tc:GetLinkMarker()-lk[op]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
	e1:SetValue(link)
	e1:SetReset(RESET_EVENT+0x01fe0000)
	tc:RegisterEffect(e1,true)
	Duel.RaiseEvent(tc,EVENT_CUSTOM+39507090+tc:GetCode(),e,0,tp,tp,link)
	if g:GetCount()==0 then return end
	--Second Card
	if not ac:IsRelateToEffect(e) or ac==tc then return end
	lk,ops=Card.LinkCheck(ac,1)
	Duel.HintSelection(Group.FromCards(ac))
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,9))
	local op=Duel.SelectOption(tp,table.unpack(ops))
	link=ac:GetLinkMarker()+lk[op]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
	e2:SetValue(link)
	e2:SetReset(RESET_EVENT+0x01fe0000)
	ac:RegisterEffect(e2,true)
	Duel.RaiseEvent(ac,EVENT_CUSTOM+39507091+ac:GetCode(),e,0,tp,tp,link)
end