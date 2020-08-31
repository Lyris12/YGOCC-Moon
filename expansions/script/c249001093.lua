--Neo-Tempester Data Analyst
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249001093.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63528891,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c249001093.spcon)
	c:RegisterEffect(e1)
	--add
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,2490010931)
	e2:SetCondition(c249001093.addcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c249001093.addtg)
	e2:SetOperation(c249001093.addop)
	c:RegisterEffect(e2)
	--level change
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9583383,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,2490010932)
	e3:SetCost(c249001093.lvcost)
	e3:SetOperation(c249001093.lvop)
	c:RegisterEffect(e3)
end
function c249001093.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x228)
end
function c249001093.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c249001093.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function c249001093.ctfilter(c)
	return c:IsSetCard(0x228) and c:IsType(TYPE_MONSTER)
end
function c249001093.addcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249001093.ctfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	local ct=g:GetClassCount(Card.GetCode)
	return ct > 1 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)>=2
end
function c249001093.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001093.addop(e,tp,eg,ep,ev,re,r,rp)
	local ac
	local cc
	repeat
		ac=Duel.AnnounceCard(tp,TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE)
		cc=Duel.CreateToken(tp,ac)
	until not banned_list_table[ac]
	Duel.SendtoDeck(cc,nil,2,REASON_RULE)
	local ct=Duel.Draw(tp,1,REASON_EFFECT)
	if ct==0 then return end
	local dc=Duel.GetOperatedGroup():GetFirst()
	if dc:IsSetCard(0x228) and Duel.IsPlayerCanDraw(tp,1)
		and Duel.SelectYesNo(tp,aux.Stringid(69584564,0)) then
		Duel.BreakEffect()
		Duel.ConfirmCards(1-tp,dc)
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.ShuffleHand(tp)
	end
end
function c249001093.rfilter(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(c249001093.tfilter,tp,LOCATION_MZONE,0,1,nil,lv)
end
function c249001093.tfilter(c,clv)
	return not c:IsLevel(clv) and c:IsLevelAbove(1) and c:IsFaceup() and c:IsSetCard(0x228)
end
function c249001093.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c249001093.rfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,c249001093.rfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local lv=g:GetFirst():GetLevel()
	Duel.SetTargetParam(lv)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function c249001093.lvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249001093.cfilter,tp,LOCATION_MZONE,0,nil)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local tc=g:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
