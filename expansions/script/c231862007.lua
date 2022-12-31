--created by ZEN, coded by TaxingCorn117
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(math.floor(id/100),0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.sumcon)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCondition(s.imcon)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DICE+CATEGORY_DAMAGE)
	e3:SetTarget(s.tg)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		s[1]=0
		s[2]=0
		s[3]=0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		e2:SetOperation(function(e) s[0]=0 s[1]=0 s[2]=0 s[3]=0 end)
		Duel.RegisterEffect(e2,0)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_DAMAGE)
		e5:SetOperation(s.count)
		Duel.RegisterEffect(e5,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_TOSS_DICE_NEGATE)
		e3:SetOperation(s.addcount)
		Duel.RegisterEffect(e3,0)
	end
end
function s.count(e,tp,eg,ep,ev,re,r,rp)
	s[ep]=s[ep]+ev
end
function s.addcount(e,tp,eg,ep,ev,re,r,rp)
	local cc=Duel.GetCurrentChain()
	local ci=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	if s[4]~=ci then
		local dc={Duel.GetDiceResult()}
		for _,ct in ipairs(dc) do s[2+ep]=s[2+ep]+ct end
		Duel.SetDiceResult(table.unpack(dc))
		s[4]=ci
	end
end
function s.sumcon(e,c)
	if c==nil then return true end
	return s[2+c:GetControler()]>23
end
function s.imcon(e)
	return s[e:GetHandlerPlayer()]>=2500
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x52f) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelAbove(1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and (c:IsControler(tp) or c:IsLocation(LOCATION_REMOVED)) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,tg:GetFirst():GetLevel())
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) then
		Duel.BreakEffect()
		local lv=tc:GetLevel()
		local d=0
		for i=1,math.ceil(tc:GetLevel()/5) do
			local t={Duel.TossDice(tp,math.min(lv,5))}
			for _,v in ipairs(t) do d=d+v end
			if lv<=5 then break end
			lv=lv-5
		end
		Duel.Damage(1-tp,d*100,REASON_EFFECT)
	end
end
