--Santuario Nascosto di Soletluna
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:Activate()
	--Trap activate in set turn
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetTarget(s.acttg)
	c:RegisterEffect(e1)
	--increase energy
	c:Ignition(1,nil,EFFECT_FLAG_CARD_TARGET,nil,true,
		nil,
		nil,
		s.entg,
		s.enop
	)
	--search1
	c:SummonedFieldTrigger(s.cfilter(SUMMON_TYPE_PANDEMONIUM),false,false,true,false,2,CATEGORIES_SEARCH,EFFECT_FLAG_DELAY,nil,true,
		nil,
		nil,
		aux.SearchTarget(s.scfilter),
		s.scop
	)
	--search2
	c:SummonedFieldTrigger(s.cfilter(SUMMON_TYPE_DRIVE),false,false,true,false,3,CATEGORIES_SEARCH,EFFECT_FLAG_DELAY,nil,true,
		nil,
		nil,
		s.sctg2,
		s.scop2
	)
end
function s.acttg(e,c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x209)
end

function s.enfilter(c,tp,en)
	local lv=c:GetLevel()
	return c:IsFaceup() and lv>0 and en:IsCanUpdateEnergy(lv,tp,REASON_EFFECT)
end
function s.entg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local en=Duel.GetEngagedCard(tp)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.enfilter(chkc,tp,en) end
	if chk==0 then
		return en and en:IsMonster() and en:IsSetCard(0x209) and Duel.IsExistingTarget(s.enfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,en)
	end
	Duel.HintMessage(tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.enfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,en)
end
function s.enop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local en=Duel.GetEngagedCard(tp)
	if not tc or not tc:IsRelateToChain() or not tc:IsFaceup()
		or not en or not en:IsMonster() or not en:IsSetCard(0x209) or not en:IsCanUpdateEnergy(tc:GetLevel(),tp,REASON_EFFECT) then
		return
	end
	en:UpdateEnergy(tc:GetLevel(),tp,REASON_EFFECT,0,e:GetHandler())
end

function s.cfilter(sumtyp)
	return	function(c)
				return c:IsFaceup() and c:IsSetCard(0x209) and c:IsSummonType(sumtyp)
			end
end
function s.scfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsSetCard(0x209)
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.HintMessage(tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:IsExists(aux.PLChk,1,nil,tp,LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		if tc:IsCanEngage(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			tc:Engage(e,tp)
		end
	end
end

function s.scfilter2(c,e,tp,eg,ep,ev,re,r,rp)
	return c:IsMonster(TYPE_PANDEMONIUM) and c:IsSetCard(0x209)
		and (c:IsAbleToHand() or aux.PandSSetCon(tc,tp)(e,tp,eg,ep,ev,re,r,rp))
end
function s.sctg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.scfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.scop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.HintMessage(tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.scfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		local b1=tc:IsAbleToHand()
		local b2=aux.PandSSetCon(tc,tp)(e,tp,eg,ep,ev,re,r,rp)
		local opt=aux.Option(id,tp,5,b1,b2)
		if opt==0 then
			Duel.Search(tc,tp)
		elseif opt==1 then
			aux.PandSSet(tc,REASON_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		end
	end
end