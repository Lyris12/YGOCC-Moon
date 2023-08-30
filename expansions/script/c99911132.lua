--Anguish from the Dark
--Fixed by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP,1)
	e1:HOPT(true)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--discard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetTarget(s.hdtg)
	e2:SetOperation(s.hdop)
	c:RegisterEffect(e2)
	--control
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.cfilter,id,LOCATION_MZONE,nil,LOCATION_MZONE,nil,id+100)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+s.progressive_id)
	e3:SetRange(LOCATION_MZONE)
	e3:HOPT()
	e3:SetTarget(s.ctltg)
	e3:SetOperation(s.ctlop)
	c:RegisterEffect(e3)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
end

function s.dcfilter(c)
	return c:IsMonster() and c:IsRace(RACE_ZOMBIE) and c:IsDiscardable(REASON_EFFECT)
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DiscardHand(1-tp,s.dcfilter,1,1,REASON_EFFECT|REASON_DISCARD,nil)
end

function s.cfilter(c,e,_,eg,_,_,_,_,_,se)
	return c:IsFaceup() and c:IsSetCard(ARCHE_FROM_THE_DARK) and (not eg:IsContains(e:GetHandler()) or (se==nil or c:GetReasonEffect()~=se))
end
function s.ctltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g
	if #eg>1 then
		Duel.HintMessage(tp,aux.Stringid(id,3))
		g=eg:SelectSubGroup(tp,aux.SimultaneousEventGroupCheck,false,1,#eg,id+100,eg)
		Duel.HintSelection(g)
	else
		g=eg:Clone()
	end
	local tgp=0
	for p=0,1 do
		if g:IsExists(Card.IsSummonPlayer,1,nil,p) then
			tgp=tgp|(p+1)
		end
	end
	e:SetLabel(tgp)
	Duel.SetCardOperationInfo(e:GetHandler(),CATEGORY_CONTROL)
end
function s.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local p=e:GetLabel()
	if p&(2-c:GetControler())==0 then return end
	Duel.GetControl(c,1-c:GetControler())
end