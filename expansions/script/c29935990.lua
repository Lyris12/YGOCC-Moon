--Deus Automata
--Script by XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.ffilter,2,true)
	aux.AddContactFusionProcedureGlitchy(c,0,true,0,Card.IsAbleToDeckOrExtraAsCost,LOCATION_MZONE,0,{s.ffcon,aux.tdcfop(c)})
	--ss condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--search
	c:Quick(false,1,CATEGORIES_SEARCH,nil,nil,nil,true,
		aux.MainPhaseCond(),
		nil,
		aux.SearchTarget(aux.MonsterFilter(Card.IsSetCard,0x48a),1,LOCATION_DECK+LOCATION_GRAVE),
		s.scop,
		RELEVANT_TIMINGS
	)
	--send to GY
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ENGAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetTarget(aux.SendToGYTarget(nil,LOCATION_ONFIELD,LOCATION_ONFIELD))
	e3:SetOperation(aux.SendToGYOperation(nil,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1))
	c:RegisterEffect(e3)
	--global counter
	if not s.global_check then
		s.global_check=true
		aux.EnableSummonCounter(c,false,true,false,s.glfilter,RESET_PHASE+PHASE_END)
	end		
end
function s.glfilter(c)
	return c:IsSummonType(SUMMON_TYPE_DRIVE)
end
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x48a) and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
function s.ffcon(e,c,tp,mg)
	return Duel.PlayerHasFlagEffect(tp,id)
end

function s.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end

function s.scfilter(c)
	return c:IsMonster() and c:IsSetCard(0x48a) and c:IsAbleToHand()
end
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.NecroValleyFilter(s.scfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		local tc=g:GetFirst()
		if aux.PLChk(tc,tp,LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,g)
			if tc:IsMonster(TYPE_DRIVE) and tc:IsCanEngage(tp) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				tc:Engage(e,tp)
			end
		end
	end
end