--Neo-Tempester Data Compiler
xpcall(function() require("expansions/script/bannedlist") end,function() require("script/bannedlist") end)
function c249001094.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9523599,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,2490010941)
	e1:SetCondition(c249001094.spcon)
	e1:SetTarget(c249001094.sptg)
	e1:SetOperation(c249001094.spop)
	c:RegisterEffect(e1)
	--add
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,24900010942)
	e2:SetCondition(c249001094.addcon)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c249001094.addtg)
	e2:SetOperation(c249001094.addop)
	c:RegisterEffect(e2)
end
function c249001094.spcon(e,tp,eg,ep,ev,re,r,rp)
	return (r==REASON_LINK) or (r==REASON_SYNCHRO)
end
function c249001094.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsSetCard(0x228)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function c249001094.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local mg=e:GetHandler():GetReasonCard():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c249001094.spfilter(chkc,e,tp) and chkc~=c end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c249001094.spfilter,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=mg:FilterSelect(tp,c249001094.spfilter,1,1,c,e,tp)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c249001094.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function c249001094.ctfilter(c)
	return c:IsSetCard(0x228) and c:IsType(TYPE_MONSTER)
end
function c249001094.addcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c249001094.ctfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	local ct=g:GetClassCount(Card.GetCode)
	return ct > 1 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE,nil)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)>=2
end
function c249001094.addtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c249001094.addop(e,tp,eg,ep,ev,re,r,rp)
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