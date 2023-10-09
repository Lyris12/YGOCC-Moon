--Shadowflame Calvalry
--Design and code by Kindrindra

local s,id=GetID()
function s.initial_effect(c)
    --Destroy
    local e1=Effect.CreateEffect(c)
	e1:Desc(0)
    e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:HOPT()
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)
    --Special Summon
    local e2=Effect.CreateEffect(c)
	e2:Desc(1)
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
    e2:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
    e2:HOPT()
    e2:SetCondition(s.sscon)
    e2:SetTarget(s.sstg)
    e2:SetOperation(s.ssop)
    c:RegisterEffect(e2)
end

function s.filter(c)
	return c:IsSpellTrapOnField() and Duel.IsPlayerCanDraw(c:GetControler(),1)
end
function s.gcheck(g)
	for p=0,1 do
		local ct=g:FilterCount(Card.IsControler,nil,p)
		if ct>0 and not Duel.IsPlayerCanDraw(p,ct) then
			return false
		end
	end
	return true
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    local c=e:GetHandler()
	local exc=aux.ActivateException(e,chk==0)
	local g=Duel.Group(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
    if chkc then return chkc:IsOnField() and chkc:IsSpellTrapOnField() and chkc~=exc end
    if chk==0 then return g:FilterCount(Card.IsCanBeEffectTarget,nil,e)>0 end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local sg=g:Filter(Card.IsCanBeEffectTarget,nil,e):SelectSubGroup(tp,s.gcheck,false,1,2)
	Duel.SetTargetCard(sg)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	local player,count
	for p=0,1 do
		local ct=sg:FilterCount(Card.IsControler,nil,p)
		if ct>0 then
			player = (player==nil) and p or PLAYER_ALL
			count = ct
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,player,count)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local sg=Duel.GetTargetCards()
	if #sg==0 then return end
    if Duel.Destroy(sg,REASON_EFFECT)>0 then
		sg=Duel.GetOperatedGroup()
		local d={0,0}
		for p=0,1 do
			local ct=sg:FilterCount(Card.IsPreviousControler,nil,p)
			d[p+1]=ct
		end
		local turnp=Duel.GetTurnPlayer()
		if d[turnp+1]>0 then
			Duel.Draw(Duel.GetTurnPlayer(),d[turnp+1],REASON_EFFECT)
		end
		if d[2-turnp]>0 then
			Duel.Draw(1-Duel.GetTurnPlayer(),d[2-turnp],REASON_EFFECT)
		end
	end
end

--Special Summon
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
function s.ssfilter(c,e,tp)
    return c:IsType(TYPE_TRAP) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetCode(),0,TYPE_MONSTER|TYPE_NORMAL,1700,800,4,RACE_PYRO,ATTRIBUTE_DARK)
end
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
    local c=e:GetHandler()
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingTarget(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
    end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tc=Duel.SelectTarget(tp,s.ssfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
    Duel.SetCardOperationInfo(tc,CATEGORY_SPECIAL_SUMMON)
end
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToChain() then
        tc:AddMonsterAttribute(TYPE_NORMAL,ATTRIBUTE_DARK,RACE_PYRO,4,1700,800)
		Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
    end
end